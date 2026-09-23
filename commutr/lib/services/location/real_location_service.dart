import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

/// Real device GPS provider implemented with Geolocator
class RealLocationService implements LocationService {
  final _positionController = StreamController<UserPosition>.broadcast();
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;

  @override
  Stream<UserPosition> get positionStream => _positionController.stream;

  @override
  bool get isTracking => _isTracking;

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  @override
  Future<LocationPermissionState> checkAndRequestPermission() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionState.serviceDisabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionState.granted;
        case LocationPermission.denied:
          return LocationPermissionState.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionState.permanentlyDenied;
        case LocationPermission.unableToDetermine:
          return LocationPermissionState.unknown;
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return LocationPermissionState.unknown;
    }
  }

  @override
  Future<UserPosition?> getCurrentPosition() async {
    try {
      final permission = await checkAndRequestPermission();
      if (permission != LocationPermissionState.granted) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return _mapPosition(pos);
    } catch (e) {
      debugPrint('Error getting current GPS fix: $e');
      return null;
    }
  }

  @override
  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters movement
    );

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        final userPos = _mapPosition(position);
        _positionController.add(userPos);
      },
      onError: (error) {
        debugPrint('GPS stream error: $error');
      },
    );
  }

  @override
  void stopTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  UserPosition _mapPosition(Position pos) {
    // pos.speed is in m/s; convert to km/h (1 m/s = 3.6 km/h)
    double? speedKmh;
    if (pos.speed > 0.5) {
      speedKmh = pos.speed * 3.6;
    } else {
      speedKmh = 0.0;
    }

    return UserPosition(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracyMeters: pos.accuracy,
      altitudeMeters: pos.altitude,
      speedKmh: speedKmh,
      headingDegrees: pos.heading > 0 ? pos.heading : null,
      timestamp: pos.timestamp,
    );
  }

  @override
  void dispose() {
    stopTracking();
    _positionController.close();
  }
}
