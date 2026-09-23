import 'dart:math' as math;
import '../../models/transit_route.dart';
import '../../models/transit_stop.dart';

/// Result of matching a GPS location onto a transit route geometry
class RouteMatchResult {
  final double snappedLatitude;
  final double snappedLongitude;
  final double headingDegrees;
  final int segmentIndex;
  final double progressPercent; // 0.0 to 100.0
  final double remainingDistanceKm;
  final double distanceFromRouteMeters;
  final bool isSnapped;
  final String nextStopId;
  final String currentStopId;

  const RouteMatchResult({
    required this.snappedLatitude,
    required this.snappedLongitude,
    required this.headingDegrees,
    required this.segmentIndex,
    required this.progressPercent,
    required this.remainingDistanceKm,
    required this.distanceFromRouteMeters,
    required this.isSnapped,
    required this.nextStopId,
    required this.currentStopId,
  });
}

/// Service that matches GPS points against route polyline geometry
class RouteMatchingService {
  static const double earthRadiusKm = 6371.0;
  static const double snapThresholdMeters = 75.0; // Max distance to constrain to route

  /// Calculate distance between two lat/lng points in kilometers (Haversine)
  static double distanceKm(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculate bearing from point 1 to point 2 in degrees (0 - 360)
  static double bearingDegrees(double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = _degToRad(lat1);
    final lat2Rad = _degToRad(lat2);
    final dLonRad = _degToRad(lon2 - lon1);

    final y = math.sin(dLonRad) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLonRad);

    final rad = math.atan2(y, x);
    return (_radToDeg(rad) + 360) % 360;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);

  /// Calculate total length of polyline in kilometers
  static double calculateTotalLengthKm(List<GeoCoord> polyline) {
    if (polyline.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < polyline.length - 1; i++) {
      total += distanceKm(
        polyline[i].latitude,
        polyline[i].longitude,
        polyline[i + 1].latitude,
        polyline[i + 1].longitude,
      );
    }
    return total;
  }

  /// Match a raw GPS point onto route geometry
  static RouteMatchResult matchToRoute({
    required double latitude,
    required double longitude,
    required List<GeoCoord> polyline,
    required List<TransitStop> stops,
  }) {
    if (polyline.length < 2) {
      return RouteMatchResult(
        snappedLatitude: latitude,
        snappedLongitude: longitude,
        headingDegrees: 0.0,
        segmentIndex: 0,
        progressPercent: 0.0,
        remainingDistanceKm: 0.0,
        distanceFromRouteMeters: 0.0,
        isSnapped: false,
        nextStopId: stops.isNotEmpty ? stops[0].id : '',
        currentStopId: stops.isNotEmpty ? stops[0].id : '',
      );
    }

    double minDistanceKm = double.infinity;
    int closestSegmentIndex = 0;
    double bestSnappedLat = latitude;
    double bestSnappedLng = longitude;

    // Find closest segment
    for (int i = 0; i < polyline.length - 1; i++) {
      final a = polyline[i];
      final b = polyline[i + 1];

      // Approximate flat-earth projection for short road segments
      final segDx = b.longitude - a.longitude;
      final segDy = b.latitude - a.latitude;
      final segLenSq = segDx * segDx + segDy * segDy;

      double t = 0.0;
      if (segLenSq > 1e-12) {
        t = ((longitude - a.longitude) * segDx + (latitude - a.latitude) * segDy) / segLenSq;
        t = t.clamp(0.0, 1.0);
      }

      final projLat = a.latitude + t * segDy;
      final projLng = a.longitude + t * segDx;

      final dist = distanceKm(latitude, longitude, projLat, projLng);
      if (dist < minDistanceKm) {
        minDistanceKm = dist;
        closestSegmentIndex = i;
        bestSnappedLat = projLat;
        bestSnappedLng = projLng;
      }
    }

    final distanceMeters = minDistanceKm * 1000.0;
    final isSnapped = distanceMeters <= snapThresholdMeters;

    // Segment heading
    final pA = polyline[closestSegmentIndex];
    final pB = polyline[closestSegmentIndex + 1];
    final heading = bearingDegrees(pA.latitude, pA.longitude, pB.latitude, pB.longitude);

    // Calculate total length and progress
    double coveredDistanceKm = 0.0;
    for (int i = 0; i < closestSegmentIndex; i++) {
      coveredDistanceKm += distanceKm(
        polyline[i].latitude,
        polyline[i].longitude,
        polyline[i + 1].latitude,
        polyline[i + 1].longitude,
      );
    }
    coveredDistanceKm += distanceKm(
      pA.latitude,
      pA.longitude,
      bestSnappedLat,
      bestSnappedLng,
    );

    final totalLengthKm = calculateTotalLengthKm(polyline);
    final progressPercent = totalLengthKm > 0
        ? (coveredDistanceKm / totalLengthKm * 100.0).clamp(0.0, 100.0)
        : 0.0;
    final remainingDistanceKm = math.max(0.0, totalLengthKm - coveredDistanceKm);

    // Determine current & next stop
    String currentStopId = stops.isNotEmpty ? stops[0].id : '';
    String nextStopId = stops.length > 1 ? stops[1].id : (stops.isNotEmpty ? stops[0].id : '');

    // Map progress against stops
    if (stops.isNotEmpty) {
      double minStopDist = double.infinity;
      int closestStopIndex = 0;

      for (int i = 0; i < stops.length; i++) {
        final d = distanceKm(bestSnappedLat, bestSnappedLng, stops[i].latitude, stops[i].longitude);
        if (d < minStopDist) {
          minStopDist = d;
          closestStopIndex = i;
        }
      }

      currentStopId = stops[closestStopIndex].id;
      final nextIndex = math.min(closestStopIndex + 1, stops.length - 1);
      nextStopId = stops[nextIndex].id;
    }

    return RouteMatchResult(
      snappedLatitude: isSnapped ? bestSnappedLat : latitude,
      snappedLongitude: isSnapped ? bestSnappedLng : longitude,
      headingDegrees: heading,
      segmentIndex: closestSegmentIndex,
      progressPercent: progressPercent,
      remainingDistanceKm: remainingDistanceKm,
      distanceFromRouteMeters: distanceMeters,
      isSnapped: isSnapped,
      nextStopId: nextStopId,
      currentStopId: currentStopId,
    );
  }
}
