import 'dart:async';
import 'location_service.dart';

/// Predictable simulated sensor provider for hackathon demonstration
class DemoLocationProvider implements LocationService {
  final _positionController = StreamController<UserPosition>.broadcast();
  Timer? _ticker;
  bool _isTracking = false;

  final List<List<double>> demoCoordinates;
  int _currentIndex = 0;

  DemoLocationProvider({required this.demoCoordinates});

  @override
  Stream<UserPosition> get positionStream => _positionController.stream;

  @override
  bool get isTracking => _isTracking;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermissionState> checkAndRequestPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<UserPosition?> getCurrentPosition() async {
    if (demoCoordinates.isEmpty) return null;
    final coord = demoCoordinates[_currentIndex.clamp(0, demoCoordinates.length - 1)];
    return UserPosition(
      latitude: coord[0],
      longitude: coord[1],
      accuracyMeters: 8.0,
      speedKmh: 28.5,
      timestamp: DateTime.now(),
    );
  }

  @override
  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 2), (_) {
      if (demoCoordinates.isEmpty) return;
      _currentIndex = (_currentIndex + 1) % demoCoordinates.length;
      final pt = demoCoordinates[_currentIndex];

      _positionController.add(
        UserPosition(
          latitude: pt[0],
          longitude: pt[1],
          accuracyMeters: 6.5,
          speedKmh: 31.0,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  void stopTracking() {
    _isTracking = false;
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    stopTracking();
    _positionController.close();
  }
}
