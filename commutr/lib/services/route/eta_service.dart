import 'dart:math' as math;

/// Local prototype ETA service calculating truthful arrival time estimates
class EtaService {
  static const double defaultUrbanSpeedKmh = 22.0; // Typical Thane municipal speed with signals
  static const double stopDwellMinutes = 0.75; // 45 seconds per stop

  /// Calculate estimated arrival in minutes
  static int calculateEtaMinutes({
    required double remainingDistanceKm,
    required double? currentSpeedKmh,
    required int remainingStopsCount,
  }) {
    if (remainingDistanceKm <= 0.05) {
      return 1;
    }

    // Use current speed if moving reasonably, otherwise fallback to typical corridor speed
    double effectiveSpeedKmh = defaultUrbanSpeedKmh;
    if (currentSpeedKmh != null && currentSpeedKmh > 8.0) {
      // Smooth between current speed and corridor baseline
      effectiveSpeedKmh = (currentSpeedKmh * 0.7) + (defaultUrbanSpeedKmh * 0.3);
    }

    // Travel time in minutes
    final travelMinutes = (remainingDistanceKm / effectiveSpeedKmh) * 60.0;
    // Dwell buffer for passenger boarding at intermediate stops
    final dwellMinutes = remainingStopsCount * stopDwellMinutes;

    final totalMinutes = (travelMinutes + dwellMinutes).round();
    return math.max(1, totalMinutes);
  }
}
