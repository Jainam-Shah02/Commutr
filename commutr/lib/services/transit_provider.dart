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

/// Central State Provider for Commutr Real-time Bus Tracking, Sensor Fusion & Route GIS
class TransitProvider extends ChangeNotifier {
  TransitRoute _selectedRoute = DemoDataService.routeTmt50;
  bool _isSimulating = true;
  TrackingSource _trackingSource = TrackingSource.crowd;
  ServiceStatus _serviceStatus = ServiceStatus.normal;
  bool _followBus = true;
  String _destinationStopId = 'stop-7'; // default: Manpada
  bool _driverModeActive = false;
  bool _isLiveAvailable = true;
  int _coordIndex = 17; // Initial index near Majiwada Junction
  int _lastUpdatedSec = 8;
  bool _passengerRideActive = false;

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
      safeIndex = _coordIndex.clamp(0, polyline.length - 1);
      final rawPoint = polyline[safeIndex];
      rawLat = rawPoint.latitude;
      rawLon = rawPoint.longitude;
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

  void _startTimers() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!_isSimulating ||
          !_isLiveAvailable ||
          _serviceStatus == ServiceStatus.confirmedDisruption) {
        return;
      }
      final polyline = activePolyline;
      if (polyline.isEmpty) return;

      _coordIndex = (_coordIndex + 1) >= polyline.length ? 0 : _coordIndex + 1;
      _lastUpdatedSec = math.Random().nextInt(5) + 3;
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
    notifyListeners();
  }

  void toggleLiveAvailable() {
    _isLiveAvailable = !_isLiveAvailable;
    _trackingSource =
        _isLiveAvailable ? TrackingSource.crowd : TrackingSource.noLiveData;
    notifyListeners();
  }

  void resetSimulation() {
    _coordIndex = 17;
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
