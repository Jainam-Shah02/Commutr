/// Tracking source indicating sensor / verification origin
enum TrackingSource {
  crowd, // Crowd-sourced from verified passenger phones
  driver, // Operator/driver phone anchor
  hybrid, // Fused crowd + driver anchor
  lastKnown, // Stale signal extrapolation
  scheduled, // Timetable extrapolation, no live sensors
  noLiveData, // No reliable live signal
}

extension TrackingSourceExtension on TrackingSource {
  String get label {
    switch (this) {
      case TrackingSource.crowd:
        return 'CROWD';
      case TrackingSource.driver:
        return 'DRIVER';
      case TrackingSource.hybrid:
        return 'HYBRID';
      case TrackingSource.lastKnown:
        return 'LAST_KNOWN';
      case TrackingSource.scheduled:
        return 'SCHEDULED';
      case TrackingSource.noLiveData:
        return 'NO_LIVE_DATA';
    }
  }

  String get displayTitle {
    switch (this) {
      case TrackingSource.crowd:
        return 'Crowd-verified location';
      case TrackingSource.driver:
        return 'Driver verified anchor';
      case TrackingSource.hybrid:
        return 'Hybrid fused location';
      case TrackingSource.lastKnown:
        return 'Last known position';
      case TrackingSource.scheduled:
        return 'Scheduled timetable';
      case TrackingSource.noLiveData:
        return 'Live location unavailable';
    }
  }
}

/// Service status state for disruptions and deviations
enum ServiceStatus {
  normal,
  possibleDisruption, // System or unconfirmed passenger report
  confirmedDisruption, // Confirmed by operator
  detour, // Route deviation active
}

extension ServiceStatusExtension on ServiceStatus {
  String get label {
    switch (this) {
      case ServiceStatus.normal:
        return 'NORMAL';
      case ServiceStatus.possibleDisruption:
        return 'POSSIBLE_DISRUPTION';
      case ServiceStatus.confirmedDisruption:
        return 'CONFIRMED_DISRUPTION';
      case ServiceStatus.detour:
        return 'DETOUR';
    }
  }
}

/// Crowding / occupancy level
enum OccupancyLevel {
  low, // Seats likely available
  moderate, // Moderately crowded
  high, // Mostly occupied / standing room
}

extension OccupancyLevelExtension on OccupancyLevel {
  String get displayText {
    switch (this) {
      case OccupancyLevel.low:
        return 'Seats likely available';
      case OccupancyLevel.moderate:
        return 'Moderately crowded';
      case OccupancyLevel.high:
        return 'Standing room likely';
    }
  }
}

/// Confidence in the estimated virtual bus state
enum ConfidenceLevel {
  high, // High confidence
  medium, // Medium confidence
  limited, // Limited live data
  none, // No live data
}

extension ConfidenceLevelExtension on ConfidenceLevel {
  String get displayText {
    switch (this) {
      case ConfidenceLevel.high:
        return 'High confidence';
      case ConfidenceLevel.medium:
        return 'Medium confidence';
      case ConfidenceLevel.limited:
        return 'Limited live data';
      case ConfidenceLevel.none:
        return 'No live data';
    }
  }

  String get label => displayText;
}

/// Real-time virtual bus state aggregated from crowd / driver sensors
class BusState {
  final String id;
  final String routeId;
  final String operator;
  final String routeNumber;
  final double latitude;
  final double longitude;
  final double heading; // 0-360 degrees
  final double speedKmh;
  final int currentCoordinateIndex;
  final String currentStopId;
  final String nextStopId;
  final int etaMinutes;
  final int progressPercent;
  final OccupancyLevel occupancy;
  final TrackingSource trackingSource;
  final ConfidenceLevel confidence;
  final ServiceStatus serviceStatus;
  final int lastUpdatedSec;
  final String? disruptionMessage;

  const BusState({
    required this.id,
    required this.routeId,
    required this.operator,
    required this.routeNumber,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speedKmh,
    required this.currentCoordinateIndex,
    required this.currentStopId,
    required this.nextStopId,
    required this.etaMinutes,
    required this.progressPercent,
    required this.occupancy,
    required this.trackingSource,
    required this.confidence,
    required this.serviceStatus,
    required this.lastUpdatedSec,
    this.disruptionMessage,
  });

  BusState copyWith({
    String? id,
    String? routeId,
    String? operator,
    String? routeNumber,
    double? latitude,
    double? longitude,
    double? heading,
    double? speedKmh,
    int? currentCoordinateIndex,
    String? currentStopId,
    String? nextStopId,
    int? etaMinutes,
    int? progressPercent,
    OccupancyLevel? occupancy,
    TrackingSource? trackingSource,
    ConfidenceLevel? confidence,
    ServiceStatus? serviceStatus,
    int? lastUpdatedSec,
    String? disruptionMessage,
  }) {
    return BusState(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      operator: operator ?? this.operator,
      routeNumber: routeNumber ?? this.routeNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speedKmh: speedKmh ?? this.speedKmh,
      currentCoordinateIndex: currentCoordinateIndex ?? this.currentCoordinateIndex,
      currentStopId: currentStopId ?? this.currentStopId,
      nextStopId: nextStopId ?? this.nextStopId,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      progressPercent: progressPercent ?? this.progressPercent,
      occupancy: occupancy ?? this.occupancy,
      trackingSource: trackingSource ?? this.trackingSource,
      confidence: confidence ?? this.confidence,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      lastUpdatedSec: lastUpdatedSec ?? this.lastUpdatedSec,
      disruptionMessage: disruptionMessage ?? this.disruptionMessage,
    );
  }
}
