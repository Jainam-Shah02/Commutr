import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/transit_route.dart';
import '../models/bus_state.dart';
import 'demo_data_service.dart';
import 'location/location_service.dart';
import 'location/real_location_service.dart';
import 'location/demo_location_provider.dart';
import 'route/route_matching_service.dart';
import 'route/eta_service.dart';
import 'backend_transit_provider.dart';
import 'realtime/transit_realtime_service.dart';

enum TrackingMode {
  tracking, // "I'm tracking this bus" - waiting for bus
  travelling, // "I'm travelling on this bus" - onboard passenger
}

class RecentSearch {
  final String from;
  final String to;
  final DateTime timestamp;

  const RecentSearch({
    required this.from,
    required this.to,
    required this.timestamp,
  });
}

/// Central State Provider for Commutr Real-time Bus Tracking, Sensor Fusion & Route GIS
class TransitProvider extends ChangeNotifier {
  TransitRoute _selectedRoute = DemoDataService.routeTmt65;
  bool _isSimulating = true;
  TrackingSource _trackingSource = TrackingSource.crowd;
  ServiceStatus _serviceStatus = ServiceStatus.normal;
  bool _followBus = true;
  String _destinationStopId = 'stop-we'; // default: Wagle Estate
  bool _driverModeActive = false;
  bool _isLiveAvailable = true;
  int _coordIndex = 2; // Initial index along route
  double _simulatedDistanceMeters = 300.0; // Continuous distance along polyline (meters)
  int _lastUpdatedSec = 4;
  bool _passengerRideActive = false;
  TrackingMode _trackingMode = TrackingMode.tracking;

  // User Profile
  String _userName = 'Jainam';
  bool _isLoggedIn = true;

  // Recent Searches
  List<RecentSearch> _recentSearches = [
    RecentSearch(
      from: 'Teen Hath Naka',
      to: 'Thane Station West',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    RecentSearch(
      from: 'Mulund Check Naka',
      to: 'Cadbury Junction',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecentSearch(
      from: 'Thane Station West',
      to: 'Wagle Estate',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Real vs Demo Location Management
  late final LocationService _realLocationService;
  late final DemoLocationProvider _demoLocationProvider;
  late final BackendTransitProvider _backendTransitProvider;
  StreamSubscription<UserPosition>? _realPositionSub;
  StreamSubscription<UserPosition>? _demoPositionSub;

  UserPosition? _userPosition;
  LocationPermissionState _permissionState = LocationPermissionState.unknown;
  bool _useRealGpsForBus = false;

  Timer? _simulationTimer;
  Timer? _secondsTicker;

  TransitProvider() {
    _realLocationService = RealLocationService();
    _demoLocationProvider = DemoLocationProvider(
      demoCoordinates: DemoDataService.routeTmt50.coordinates
          .map((c) => [c.latitude, c.longitude])
          .toList(),
    );
    _backendTransitProvider = BackendTransitProvider();
    _backendTransitProvider.addListener(_onBackendUpdated);

    _initGps();
    _startTimers();
  }

  void _onBackendUpdated() {
    notifyListeners();
  }

  // Getters
  TransitRoute get selectedRoute => _selectedRoute;
  bool get isSimulating => _isSimulating;
  TrackingSource get trackingSource => _trackingSource;
  ServiceStatus get serviceStatus => _serviceStatus;
  bool get followBus => _followBus;
  String get destinationStopId => _destinationStopId;
  bool get driverModeActive => _driverModeActive;
  bool get isLiveAvailable => _isLiveAvailable;
  BackendTransitProvider get backendTransitProvider => _backendTransitProvider;
  BackendConnectionStatus get backendStatus => _backendTransitProvider.connectionStatus;
  bool get isBackendLive =>
      _backendTransitProvider.isConnected &&
      _backendTransitProvider.latestBackendPosition != null;

  String get connectionStatusBadgeText {
    switch (_backendTransitProvider.connectionStatus) {
      case BackendConnectionStatus.live:
        return 'LIVE';
      case BackendConnectionStatus.connecting:
        return 'CONNECTING';
      case BackendConnectionStatus.offline:
        return 'OFFLINE / DEMO';
    }
  }
  int get coordIndex => _coordIndex;
  int get lastUpdatedSec => _lastUpdatedSec;
  bool get passengerRideActive => _passengerRideActive;
  UserPosition? get userPosition => _userPosition;
  LocationPermissionState get permissionState => _permissionState;
  bool get useRealGpsForBus => _useRealGpsForBus;

  // Passenger & User State
  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;
  TrackingMode get trackingMode => _trackingMode;
  List<RecentSearch> get recentSearches => _recentSearches;

  void loginWithGoogle({String name = 'Jainam'}) {
    _userName = name;
    _isLoggedIn = true;
    notifyListeners();
  }

  void setTrackingMode(TrackingMode mode) {
    _trackingMode = mode;
    if (mode == TrackingMode.travelling) {
      startPassengerRide();
    } else {
      stopPassengerRide();
    }
    notifyListeners();
  }

  void addRecentSearch(String from, String to) {
    _recentSearches.removeWhere((s) => s.from == from && s.to == to);
    _recentSearches.insert(
      0,
      RecentSearch(from: from, to: to, timestamp: DateTime.now()),
    );
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.sublist(0, 5);
    }
    notifyListeners();
  }

  /// Finds the nearest bus stop to user's location
  NearestStopResult getNearestStopForUser() {
    final loc = userLocation;
    return DemoDataService.findNearestStop(loc.latitude, loc.longitude);
  }

  /// Effective user speed in km/h. If travelling on bus in demo/simulated mode, returns
  /// realistic passenger movement reading (e.g. 27.0 km/h) or actual GPS sensor speed.
  double get effectiveUserSpeedKmh {
    final posSpeed = _userPosition?.speedKmh;
    if (posSpeed != null && posSpeed > 0) {
      return posSpeed;
    }
    if (_trackingMode == TrackingMode.travelling) {
      // In onboard mode, return passenger telemetry synced with bus speed
      return (busSpeedKmh - 1.0).clamp(0.0, 100.0);
    }
    return 0.0;
  }

  /// Evaluates passenger GPS telemetry against bus movement:
  /// - Speed difference must not exceed 18 km/h
  /// - Reject walking speeds (< 6 km/h) if bus is moving at cruising speed (> 20 km/h)
  bool get isPassengerSignalReliable {
    if (_trackingMode != TrackingMode.travelling) return true;
    final userSpd = effectiveUserSpeedKmh;
    final busSpd = busSpeedKmh;

    if (busSpd > 20 && userSpd < 6) {
      return false; // Walking while bus is moving -> reject as unreliable
    }
    if ((userSpd - busSpd).abs() > 18) {
      return false; // Speed mismatch
    }
    return true;
  }

  /// Number of active passengers / contributors establishing current confidence level
  int get activePassengerContributorsCount {
    if (_serviceStatus == ServiceStatus.confirmedDisruption) return 0;
    if (!isPassengerSignalReliable) return 1;
    if (_trackingMode == TrackingMode.travelling) return 14;
    if (_trackingSource == TrackingSource.driver || isBackendLive) return 14;
    return 11;
  }

  /// Short confidence level label: High, Medium, or Limited
  String get confidenceLevelLabel {
    if (_serviceStatus == ServiceStatus.confirmedDisruption) return 'Limited';
    if (!isPassengerSignalReliable) return 'Limited';
    if (_trackingSource == TrackingSource.driver || isBackendLive) return 'High';
    if (_trackingMode == TrackingMode.travelling) return 'High';
    return 'Medium';
  }

  /// Tracking confidence representation for UI with number of people verified
  String get trackingConfidenceText {
    final count = activePassengerContributorsCount;
    final label = confidenceLevelLabel;
    if (_serviceStatus == ServiceStatus.confirmedDisruption) return 'Limited (0 people)';
    if (!isPassengerSignalReliable) return 'Limited ($count person)';
    if (_trackingMode == TrackingMode.travelling) {
      return '$label ($count people on board)';
    }
    return '$label ($count people verified)';
  }

  /// Descriptive text indicating passenger verification consensus
  String get confidencePeopleDescription {
    final count = activePassengerContributorsCount;
    if (count == 0) return 'No live passenger signals';
    if (count == 1) return '1 active passenger signal';
    return '$count people verifying this bus';
  }

  /// User location coordinates (falls back to Thane Station if GPS not granted)
  GeoCoord get userLocation {
    if (_userPosition != null) {
      return GeoCoord(_userPosition!.latitude, _userPosition!.longitude);
    }
    return const GeoCoord(19.1890, 72.9730);
  }

  /// Real speed from user's smartphone GPS in km/h (null if stationary/unavailable)
  double? get userSpeedKmh => _userPosition?.speedKmh;

  /// Estimated current bus speed in km/h
  double get busSpeedKmh {
    if (_serviceStatus == ServiceStatus.confirmedDisruption) return 0.0;
    if (_serviceStatus == ServiceStatus.possibleDisruption) return 4.0;
    if (!_isLiveAvailable) return 0.0;
    if (_selectedRoute.routeNumber == '65') return 28.0;
    return 32.0; // Typical Thane urban corridor transit cruising speed
  }

  List<GeoCoord> get activePolyline {
    if (_serviceStatus == ServiceStatus.detour && _selectedRoute.detourCoordinates != null) {
      return _selectedRoute.detourCoordinates!;
    }
    return _selectedRoute.coordinates;
  }

  /// Real-time virtual bus state with map-matching, road snapping & dynamic ETA
  BusState? get busState {
    if (!_isLiveAvailable) {
      return null; // NO LIVE DATA state (truthfulness rule: never fabricate)
    }

    final polyline = activePolyline;
    if (polyline.isEmpty) return null;

    final backendPos = _backendTransitProvider.latestBackendPosition;
    final isBackendActive = isBackendLive;

    final double rawLat;
    final double rawLon;
    final double effectiveSpeed;
    final int safeIndex;
    final TrackingSource effectiveSource;

    if (isBackendActive && backendPos != null) {
      rawLat = (backendPos['latitude'] as num).toDouble();
      rawLon = (backendPos['longitude'] as num).toDouble();
      effectiveSpeed = (backendPos['speedKmh'] as num?)?.toDouble() ?? busSpeedKmh;
      safeIndex = _coordIndex.clamp(0, polyline.length - 1);
      effectiveSource = TrackingSource.crowd;
    } else {
      final simPoint = _getSimulatedCoord(polyline);
      rawLat = simPoint.latitude;
      rawLon = simPoint.longitude;
      safeIndex = _coordIndex.clamp(0, polyline.length - 1);
      effectiveSpeed = busSpeedKmh;
      effectiveSource = _trackingSource;
    }

    // Map-matching: snap to closest route segment and compute continuous progress
    final match = RouteMatchingService.matchToRoute(
      latitude: rawLat,
      longitude: rawLon,
      polyline: polyline,
      stops: _selectedRoute.stops,
    );

    // Dynamic ETA calculation based on remaining distance, speed, and stops
    final etaMinutes = _serviceStatus == ServiceStatus.confirmedDisruption
        ? 0
        : EtaService.calculateEtaMinutes(
            remainingDistanceKm: match.remainingDistanceKm,
            currentSpeedKmh: effectiveSpeed,
            remainingStopsCount: _calculateRemainingStops(match.currentStopId),
          );

    ConfidenceLevel confidence = ConfidenceLevel.high;
    if (effectiveSource == TrackingSource.driver || isBackendActive) {
      confidence = ConfidenceLevel.high;
    } else if (effectiveSource == TrackingSource.scheduled ||
        effectiveSource == TrackingSource.lastKnown) {
      confidence = ConfidenceLevel.limited;
    }

    OccupancyLevel occupancy = match.progressPercent > 60
        ? OccupancyLevel.high
        : match.progressPercent > 30
            ? OccupancyLevel.moderate
            : OccupancyLevel.low;

    String? disruptionMessage;
    if (_serviceStatus == ServiceStatus.confirmedDisruption) {
      disruptionMessage =
          'Confirmed service disruption. Operator confirmed bus breakdown.';
    } else if (_serviceStatus == ServiceStatus.possibleDisruption) {
      disruptionMessage =
          'Possible service disruption. Unusual stop detected, awaiting operator confirmation.';
    } else if (_serviceStatus == ServiceStatus.detour) {
      disruptionMessage =
          'This bus is following a temporary route due to road blockage.';
    }

    return BusState(
      id: 'bus-${_selectedRoute.id}',
      routeId: _selectedRoute.id,
      operator: _selectedRoute.operator,
      routeNumber: _selectedRoute.routeNumber,
      latitude: match.snappedLatitude,
      longitude: match.snappedLongitude,
      heading: match.headingDegrees,
      speedKmh: effectiveSpeed,
      currentCoordinateIndex: safeIndex,
      currentStopId: match.currentStopId,
      nextStopId: match.nextStopId,
      etaMinutes: etaMinutes,
      progressPercent: match.progressPercent.round(),
      occupancy: occupancy,
      trackingSource: effectiveSource,
      confidence: confidence,
      serviceStatus: _serviceStatus,
      lastUpdatedSec: _lastUpdatedSec,
      disruptionMessage: disruptionMessage,
    );
  }

  int _calculateRemainingStops(String currentStopId) {
    final idx = _selectedRoute.stops.indexWhere((s) => s.id == currentStopId);
    if (idx < 0) return 1;
    return math.max(0, _selectedRoute.stops.length - 1 - idx);
  }

  Future<void> _initGps() async {
    _permissionState = await _realLocationService.checkAndRequestPermission();
    if (_permissionState == LocationPermissionState.granted) {
      _startRealLocationListening();
    }
  }

  Future<void> requestLocationPermission() async {
    _permissionState = await _realLocationService.checkAndRequestPermission();
    if (_permissionState == LocationPermissionState.granted) {
      _startRealLocationListening();
    }
    notifyListeners();
  }

  void _startRealLocationListening() {
    _realLocationService.startTracking();
    _realPositionSub?.cancel();
    _realPositionSub = _realLocationService.positionStream.listen(
      (UserPosition pos) {
        _userPosition = pos;
        if (_passengerRideActive || _driverModeActive) {
          _backendTransitProvider.reportObservation(
            busId: 1,
            latitude: pos.latitude,
            longitude: pos.longitude,
            speedKmh: pos.speedKmh,
            heading: pos.headingDegrees,
            accuracyMeters: pos.accuracyMeters,
          );
        }
        notifyListeners();
      },
    );
  }

  /// Computes a continuous, smoothly interpolated GPS position along the active polyline.
  /// This replicates real municipal bus vehicle telemetry advancing gradually at realistic speed (e.g. 28 km/h).
  GeoCoord _getSimulatedCoord(List<GeoCoord> polyline) {
    if (polyline.isEmpty) return const GeoCoord(19.1864, 72.9756);
    if (polyline.length == 1) return polyline.first;

    double accumulated = 0.0;
    for (int i = 0; i < polyline.length - 1; i++) {
      final p1 = polyline[i];
      final p2 = polyline[i + 1];
      final segDistMeters = RouteMatchingService.distanceKm(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      ) * 1000.0;

      if (accumulated + segDistMeters >= _simulatedDistanceMeters) {
        final remaining = _simulatedDistanceMeters - accumulated;
        final t = segDistMeters > 0 ? (remaining / segDistMeters).clamp(0.0, 1.0) : 0.0;
        _coordIndex = i;
        return GeoCoord(
          p1.latitude + (p2.latitude - p1.latitude) * t,
          p1.longitude + (p2.longitude - p1.longitude) * t,
        );
      }
      accumulated += segDistMeters;
    }

    _coordIndex = polyline.length - 1;
    return polyline.last;
  }

  void _startTimers() {
    _simulationTimer?.cancel();
    // 1-second ticks for realistic, slow, continuous vehicle movement (~7.7 meters/sec at 28 km/h)
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (!_isSimulating ||
          !_isLiveAvailable ||
          _serviceStatus == ServiceStatus.confirmedDisruption) {
        return;
      }
      final polyline = activePolyline;
      if (polyline.length < 2) return;

      final spd = busSpeedKmh;
      if (spd > 0) {
        final metersPerSecond = spd * (1000.0 / 3600.0);
        final totalLengthMeters =
            RouteMatchingService.calculateTotalLengthKm(polyline) * 1000.0;
        if (totalLengthMeters > 0) {
          _simulatedDistanceMeters =
              (_simulatedDistanceMeters + metersPerSecond) % totalLengthMeters;
        }
      }

      _lastUpdatedSec = math.Random().nextInt(3) + 1;
      notifyListeners();
    });

    _secondsTicker?.cancel();
    _secondsTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastUpdatedSec < 45) {
        _lastUpdatedSec++;
        notifyListeners();
      }
    });
  }

  // Passenger & Driver Actions
  void startPassengerRide() {
    _passengerRideActive = true;
    _trackingSource = TrackingSource.crowd;
    if (_permissionState == LocationPermissionState.granted) {
      _startRealLocationListening();
    }
    notifyListeners();
  }

  void stopPassengerRide() {
    _passengerRideActive = false;
    _realLocationService.stopTracking();
    notifyListeners();
  }

  void setDestinationStopId(String stopId) {
    _destinationStopId = stopId;
    notifyListeners();
  }

  void setSelectedRouteById(String routeId) {
    if (DemoDataService.allRoutes.containsKey(routeId)) {
      _selectedRoute = DemoDataService.allRoutes[routeId]!;
      _coordIndex = 0;
      _simulatedDistanceMeters = 200.0;
      notifyListeners();
    }
  }

  void startDriverTrip() {
    _driverModeActive = true;
    _trackingSource = TrackingSource.driver;
    _serviceStatus = ServiceStatus.normal;
    _isLiveAvailable = true;
    notifyListeners();
  }

  void endDriverTrip() {
    _driverModeActive = false;
    _trackingSource = TrackingSource.crowd;
    notifyListeners();
  }

  void reportDriverBreakdown() {
    _serviceStatus = ServiceStatus.confirmedDisruption;
    notifyListeners();
  }

  void reportPassengerProblem(String problemType) {
    _serviceStatus = ServiceStatus.possibleDisruption;
    notifyListeners();
  }

  void triggerDetour(bool active) {
    _serviceStatus = active ? ServiceStatus.detour : ServiceStatus.normal;
    _coordIndex = 0;
    _simulatedDistanceMeters = 50.0;
    notifyListeners();
  }

  void toggleLiveAvailable() {
    _isLiveAvailable = !_isLiveAvailable;
    _trackingSource =
        _isLiveAvailable ? TrackingSource.crowd : TrackingSource.noLiveData;
    notifyListeners();
  }

  void resetSimulation() {
    _coordIndex = 2;
    _simulatedDistanceMeters = 400.0;
    _serviceStatus = ServiceStatus.normal;
    _isLiveAvailable = true;
    _trackingSource = TrackingSource.crowd;
    _destinationStopId = 'stop-7';
    notifyListeners();
  }

  void setSimulating(bool sim) {
    _isSimulating = sim;
    notifyListeners();
  }

  void setFollowBus(bool follow) {
    _followBus = follow;
    notifyListeners();
  }

  void setUseRealGpsForBus(bool val) {
    _useRealGpsForBus = val;
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _secondsTicker?.cancel();
    _realPositionSub?.cancel();
    _demoPositionSub?.cancel();
    _realLocationService.dispose();
    _demoLocationProvider.dispose();
    _backendTransitProvider.removeListener(_onBackendUpdated);
    _backendTransitProvider.dispose();
    super.dispose();
  }
}
