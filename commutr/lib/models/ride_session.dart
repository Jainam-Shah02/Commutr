/// Verification state of a passenger phone's trajectory
enum RideVerificationState {
  candidate, // Phone detected near route, waiting for movement consistency
  verified, // Speed, heading, stop dwells match bus journey
  rejected, // Mismatch with bus route or stationary while bus moves
}

/// Passenger Ride Session for crowd sensing and destination tracking
class RideSession {
  final String rideId;
  final String userId;
  final String busId;
  final String routeId;
  final String originStopId;
  final String destinationStopId;
  final DateTime startTime;
  final DateTime? endTime;
  final RideVerificationState verificationState;
  final double trustScore; // 0.0 - 1.0 (RideTrust)
  final bool isSharingLocation;

  const RideSession({
    required this.rideId,
    required this.userId,
    required this.busId,
    required this.routeId,
    required this.originStopId,
    required this.destinationStopId,
    required this.startTime,
    this.endTime,
    required this.verificationState,
    required this.trustScore,
    this.isSharingLocation = true,
  });

  RideSession copyWith({
    String? rideId,
    String? userId,
    String? busId,
    String? routeId,
    String? originStopId,
    String? destinationStopId,
    DateTime? startTime,
    DateTime? endTime,
    RideVerificationState? verificationState,
    double? trustScore,
    bool? isSharingLocation,
  }) {
    return RideSession(
      rideId: rideId ?? this.rideId,
      userId: userId ?? this.userId,
      busId: busId ?? this.busId,
      routeId: routeId ?? this.routeId,
      originStopId: originStopId ?? this.originStopId,
      destinationStopId: destinationStopId ?? this.destinationStopId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      verificationState: verificationState ?? this.verificationState,
      trustScore: trustScore ?? this.trustScore,
      isSharingLocation: isSharingLocation ?? this.isSharingLocation,
    );
  }
}
