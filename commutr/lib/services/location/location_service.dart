import 'dart:async';

/// Permission and service states for device GPS
enum LocationPermissionState {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
  unknown,
}

/// Truthful representation of user location & movement telemetry
class UserPosition {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final double? altitudeMeters;
  final double? speedKmh; // null if stationary or unreliable GPS speed
  final double? headingDegrees; // 0-360 degrees
  final DateTime timestamp;

  const UserPosition({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    this.altitudeMeters,
    this.speedKmh,
    this.headingDegrees,
    required this.timestamp,
  });

  /// Check whether GPS fix is considered high accuracy (<= 30m)
  bool get isAccurate => accuracyMeters <= 30.0;
}

/// Abstract contract for location providers (Real GPS vs Demo Simulation)
abstract class LocationService {
  /// Check current permission and prompt user if required
  Future<LocationPermissionState> checkAndRequestPermission();

  /// Check if device GPS hardware service is turned on
  Future<bool> isLocationServiceEnabled();

  /// Retrieve immediate single location fix if available
  Future<UserPosition?> getCurrentPosition();

  /// Stream of continuous position updates
  Stream<UserPosition> get positionStream;

  /// Whether active sensor tracking is currently open
  bool get isTracking;

  /// Start continuous location tracking
  void startTracking();

  /// Stop tracking immediately to conserve battery and protect passenger privacy
  void stopTracking();

  /// Dispose any held stream controllers or listeners
  void dispose();
}
