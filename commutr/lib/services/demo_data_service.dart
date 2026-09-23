import 'dart:math' as math;
import '../models/transit_stop.dart';
import '../models/transit_route.dart';
import '../models/alert_item.dart';

/// Centralized Transit Dataset and Domain Data for Commutr
/// Encapsulates realistic road coordinates for TMT 50 and TMT 2 (Thane Transit)
class DemoDataService {
  DemoDataService._();

  // -------------------------------------------------------------
  // TMT 50 Stops (Thane Station West -> Manpada)
  // -------------------------------------------------------------
  static const List<TransitStop> tmt50Stops = [
    TransitStop(id: 'stop-1', name: 'Thane Station West', latitude: 19.1864, longitude: 72.9756, order: 1, isMajor: true),
    TransitStop(id: 'stop-2', name: 'Panchpakhadi', latitude: 19.1932, longitude: 72.9692, order: 2),
    TransitStop(id: 'stop-3', name: 'Nitin Company Junction', latitude: 19.1995, longitude: 72.9680, order: 3),
    TransitStop(id: 'stop-4', name: 'Cadbury Junction', latitude: 19.2045, longitude: 72.9710, order: 4, isMajor: true),
    TransitStop(id: 'stop-5', name: 'Majiwada Junction', latitude: 19.2138, longitude: 72.9785, order: 5, isMajor: true),
    TransitStop(id: 'stop-6', name: 'Kapurbawdi', latitude: 19.2225, longitude: 72.9810, order: 6),
    TransitStop(id: 'stop-7', name: 'Manpada', latitude: 19.2365, longitude: 72.9765, order: 7, isMajor: true),
  ];

  // -------------------------------------------------------------
  // TMT 50 Road Coordinates
  // -------------------------------------------------------------
  static const List<GeoCoord> tmt50Coordinates = [
    // Thane Station West
    GeoCoord(19.1864, 72.9756),
    GeoCoord(19.1872, 72.9749),
    GeoCoord(19.1883, 72.9738),
    GeoCoord(19.1898, 72.9723),
    GeoCoord(19.1915, 72.9706),
    // Panchpakhadi / Teen Hath Naka
    GeoCoord(19.1932, 72.9692),
    GeoCoord(19.1945, 72.9687),
    GeoCoord(19.1962, 72.9683),
    GeoCoord(19.1978, 72.9681),
    // Nitin Company
    GeoCoord(19.1995, 72.9680),
    GeoCoord(19.2010, 72.9687),
    GeoCoord(19.2028, 72.9698),
    // Cadbury Junction
    GeoCoord(19.2045, 72.9710),
    GeoCoord(19.2062, 72.9724),
    GeoCoord(19.2081, 72.9742),
    GeoCoord(19.2102, 72.9760),
    GeoCoord(19.2120, 72.9774),
    // Majiwada Junction
    GeoCoord(19.2138, 72.9785),
    GeoCoord(19.2155, 72.9793),
    GeoCoord(19.2175, 72.9802),
    GeoCoord(19.2198, 72.9808),
    // Kapurbawdi
    GeoCoord(19.2225, 72.9810),
    GeoCoord(19.2245, 72.9805),
    GeoCoord(19.2268, 72.9797),
    GeoCoord(19.2290, 72.9788),
    GeoCoord(19.2312, 72.9780),
    GeoCoord(19.2335, 72.9773),
    GeoCoord(19.2352, 72.9768),
    // Manpada
    GeoCoord(19.2365, 72.9765),
  ];

  // -------------------------------------------------------------
  // TMT 50 Detour Coordinates (Branching from Majiwada via Pokhran)
  // -------------------------------------------------------------
  static const List<GeoCoord> tmt50DetourCoordinates = [
    GeoCoord(19.1864, 72.9756),
    GeoCoord(19.1898, 72.9723),
    GeoCoord(19.1932, 72.9692),
    GeoCoord(19.1995, 72.9680),
    GeoCoord(19.2045, 72.9710),
    GeoCoord(19.2138, 72.9785), // Majiwada diversion start
    GeoCoord(19.2150, 72.9720), // Diversion west along Pokhran
    GeoCoord(19.2185, 72.9680),
    GeoCoord(19.2240, 72.9695),
    GeoCoord(19.2295, 72.9730),
    GeoCoord(19.2340, 72.9750),
    GeoCoord(19.2365, 72.9765), // Re-joins at Manpada
  ];

  static const List<TimetableEntry> tmt50Timetable = [
    TimetableEntry(
      period: 'morning',
      times: [
        TimetableTimeSlot(time: '07:00', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '07:20', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '07:40', status: 'LIVE'),
        TimetableTimeSlot(time: '08:00', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '08:20', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '08:40', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '09:00', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '09:30', status: 'SCHEDULED'),
      ],
    ),
    TimetableEntry(
      period: 'afternoon',
      times: [
        TimetableTimeSlot(time: '12:00', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '12:20', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '12:40', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '13:00', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '13:30', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '14:00', status: 'SCHEDULED'),
      ],
    ),
    TimetableEntry(
      period: 'evening',
      times: [
        TimetableTimeSlot(time: '17:00', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '17:20', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '17:40', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '18:00', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '18:20', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '18:40', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '19:00', status: 'SCHEDULED'),
      ],
    ),
  ];

  static const TransitRoute routeTmt50 = TransitRoute(
    id: 'tmt-50',
    operator: 'TMT',
    routeNumber: '50',
    name: 'Thane Station West → Manpada',
    origin: 'Thane Station West',
    destination: 'Manpada',
    direction: 'outbound',
    stops: tmt50Stops,
    coordinates: tmt50Coordinates,
    detourCoordinates: tmt50DetourCoordinates,
    timetable: tmt50Timetable,
  );

  // -------------------------------------------------------------
  // TMT 2 Route (Thane Station West -> Balkum)
  // -------------------------------------------------------------
  static const List<TransitStop> tmt2Stops = [
    TransitStop(id: 'stop-t2-1', name: 'Thane Station West', latitude: 19.1864, longitude: 72.9756, order: 1),
    TransitStop(id: 'stop-t2-2', name: 'Panchpakhadi', latitude: 19.1932, longitude: 72.9692, order: 2),
    TransitStop(id: 'stop-t2-3', name: 'Majiwada Junction', latitude: 19.2138, longitude: 72.9785, order: 3),
    TransitStop(id: 'stop-t2-4', name: 'Balkum Naka', latitude: 19.2240, longitude: 72.9920, order: 4),
  ];

  static const List<GeoCoord> tmt2Coordinates = [
    GeoCoord(19.1864, 72.9756),
    GeoCoord(19.1932, 72.9692),
    GeoCoord(19.2045, 72.9710),
    GeoCoord(19.2138, 72.9785),
    GeoCoord(19.2190, 72.9850),
    GeoCoord(19.2240, 72.9920),
  ];

  static const List<TimetableEntry> tmt2Timetable = [
    TimetableEntry(
      period: 'morning',
      times: [
        TimetableTimeSlot(time: '08:15', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '08:45', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '10:25', status: 'SCHEDULED'),
      ],
    ),
  ];

  static const TransitRoute routeTmt2 = TransitRoute(
    id: 'tmt-2',
    operator: 'TMT',
    routeNumber: '2',
    name: 'Thane Station West → Balkum',
    origin: 'Thane Station West',
    destination: 'Balkum',
    direction: 'outbound',
    stops: tmt2Stops,
    coordinates: tmt2Coordinates,
    timetable: tmt2Timetable,
  );

  // -------------------------------------------------------------
  // TMT 65 Route (Thane Station West -> Wagle Estate)
  // -------------------------------------------------------------
  static const List<TransitStop> tmt65Stops = [
    TransitStop(id: 'stop-t65-1', name: 'Thane Station West', latitude: 19.1864, longitude: 72.9756, order: 1, isMajor: true),
    TransitStop(id: 'stop-t65-2', name: 'Naupada', latitude: 19.1895, longitude: 72.9725, order: 2),
    TransitStop(id: 'stop-t65-3', name: 'Teen Hath Naka', latitude: 19.1932, longitude: 72.9692, order: 3, isMajor: true),
    TransitStop(id: 'stop-t65-4', name: 'Wagle Circle', latitude: 19.1950, longitude: 72.9580, order: 4),
    TransitStop(id: 'stop-t65-5', name: 'Wagle Estate', latitude: 19.1980, longitude: 72.9510, order: 5, isMajor: true),
  ];

  static const List<GeoCoord> tmt65Coordinates = [
    GeoCoord(19.1864, 72.9756),
    GeoCoord(19.1878, 72.9740),
    GeoCoord(19.1895, 72.9725),
    GeoCoord(19.1912, 72.9708),
    GeoCoord(19.1932, 72.9692),
    GeoCoord(19.1938, 72.9650),
    GeoCoord(19.1945, 72.9610),
    GeoCoord(19.1950, 72.9580),
    GeoCoord(19.1965, 72.9545),
    GeoCoord(19.1980, 72.9510),
  ];

  static const List<TimetableEntry> tmt65Timetable = [
    TimetableEntry(
      period: 'morning',
      times: [
        TimetableTimeSlot(time: '08:00', status: 'LIVE'),
        TimetableTimeSlot(time: '08:15', status: 'SCHEDULED'),
        TimetableTimeSlot(time: '08:30', status: 'SCHEDULED'),
      ],
    ),
  ];

  static const TransitRoute routeTmt65 = TransitRoute(
    id: 'tmt-65',
    operator: 'TMT',
    routeNumber: '65',
    name: 'Thane Station West → Wagle Estate',
    origin: 'Thane Station West',
    destination: 'Wagle Estate',
    direction: 'outbound',
    stops: tmt65Stops,
    coordinates: tmt65Coordinates,
    timetable: tmt65Timetable,
  );

  // -------------------------------------------------------------
  // TMT 68 Route (Mulund Check Naka -> Cadbury Junction)
  // -------------------------------------------------------------
  static const List<TransitStop> tmt68Stops = [
    TransitStop(id: 'stop-t68-1', name: 'Mulund Check Naka', latitude: 19.1820, longitude: 72.9610, order: 1, isMajor: true),
    TransitStop(id: 'stop-t68-2', name: 'Teen Hath Naka', latitude: 19.1932, longitude: 72.9692, order: 2, isMajor: true),
    TransitStop(id: 'stop-t68-3', name: 'Nitin Company Junction', latitude: 19.1995, longitude: 72.9680, order: 3),
    TransitStop(id: 'stop-t68-4', name: 'Cadbury Junction', latitude: 19.2045, longitude: 72.9710, order: 4, isMajor: true),
  ];

  static const List<GeoCoord> tmt68Coordinates = [
    GeoCoord(19.1820, 72.9610),
    GeoCoord(19.1880, 72.9650),
    GeoCoord(19.1932, 72.9692),
    GeoCoord(19.1995, 72.9680),
    GeoCoord(19.2045, 72.9710),
  ];

  static const TransitRoute routeTmt68 = TransitRoute(
    id: 'tmt-68',
    operator: 'TMT',
    routeNumber: '68',
    name: 'Mulund Check Naka → Cadbury Junction',
    origin: 'Mulund Check Naka',
    destination: 'Cadbury Junction',
    direction: 'outbound',
    stops: tmt68Stops,
    coordinates: tmt68Coordinates,
  );

  // -------------------------------------------------------------
  // Comprehensive Thane Bus Stop Dataset
  // -------------------------------------------------------------
  static const List<TransitStop> allThaneStops = [
    TransitStop(id: 'stop-1', name: 'Thane Station West', latitude: 19.1864, longitude: 72.9756, order: 1, isMajor: true),
    TransitStop(id: 'stop-thn', name: 'Teen Hath Naka', latitude: 19.1932, longitude: 72.9692, order: 2, isMajor: true),
    TransitStop(id: 'stop-2', name: 'Panchpakhadi', latitude: 19.1932, longitude: 72.9692, order: 3),
    TransitStop(id: 'stop-nau', name: 'Naupada', latitude: 19.1895, longitude: 72.9725, order: 4),
    TransitStop(id: 'stop-3', name: 'Nitin Company Junction', latitude: 19.1995, longitude: 72.9680, order: 5),
    TransitStop(id: 'stop-4', name: 'Cadbury Junction', latitude: 19.2045, longitude: 72.9710, order: 6, isMajor: true),
    TransitStop(id: 'stop-5', name: 'Majiwada Junction', latitude: 19.2138, longitude: 72.9785, order: 7, isMajor: true),
    TransitStop(id: 'stop-6', name: 'Kapurbawdi', latitude: 19.2225, longitude: 72.9810, order: 8),
    TransitStop(id: 'stop-7', name: 'Manpada', latitude: 19.2365, longitude: 72.9765, order: 9, isMajor: true),
    TransitStop(id: 'stop-8', name: 'Balkum Naka', latitude: 19.2240, longitude: 72.9920, order: 10),
    TransitStop(id: 'stop-wc', name: 'Wagle Circle', latitude: 19.1950, longitude: 72.9580, order: 11),
    TransitStop(id: 'stop-we', name: 'Wagle Estate', latitude: 19.1980, longitude: 72.9510, order: 12, isMajor: true),
    TransitStop(id: 'stop-mcn', name: 'Mulund Check Naka', latitude: 19.1820, longitude: 72.9610, order: 13, isMajor: true),
    TransitStop(id: 'stop-an', name: 'Anand Nagar', latitude: 19.2450, longitude: 72.9750, order: 14),
    TransitStop(id: 'stop-kv', name: 'Kasarvadavali', latitude: 19.2620, longitude: 72.9720, order: 15, isMajor: true),
    TransitStop(id: 'stop-ste', name: 'Thane Station East', latitude: 19.1850, longitude: 72.9790, order: 16),
  ];

  static final Map<String, TransitRoute> allRoutes = {
    'tmt-65': routeTmt65,
    'tmt65': routeTmt65,
    'tmt-50': routeTmt50,
    'tmt50': routeTmt50,
    'tmt-2': routeTmt2,
    'tmt2': routeTmt2,
    'tmt-68': routeTmt68,
    'tmt68': routeTmt68,
  };

  static List<AlertItem> initialAlerts = [
    AlertItem(
      id: 'alert-1',
      title: 'TMT 65 Approaching',
      message: 'Estimated arrival at Teen Hath Naka in ~3 min. Verified by passenger signals.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      type: AlertType.approach,
      routeNumber: '65',
      isUnread: true,
    ),
    AlertItem(
      id: 'alert-2',
      title: 'Majiwada Traffic Notice',
      message: 'Slight congestion near flyover ramp. Speeds averaged 14 km/h.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      type: AlertType.info,
      routeNumber: '50',
      isUnread: false,
    ),
  ];

  // -------------------------------------------------------------
  // Search & Filtering Utilities
  // -------------------------------------------------------------

  /// Searches Thane stops by name or partial name
  static List<TransitStop> searchStops(String query) {
    if (query.trim().isEmpty) return allThaneStops;
    final q = query.toLowerCase().trim();
    return allThaneStops.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  /// Searches routes by route number or destination/origin
  static List<TransitRoute> searchRoutes(String query) {
    if (query.trim().isEmpty) {
      return [routeTmt65, routeTmt50, routeTmt2, routeTmt68];
    }
    final q = query.toLowerCase().trim();
    final uniqueRoutes = <String, TransitRoute>{
      'tmt-65': routeTmt65,
      'tmt-50': routeTmt50,
      'tmt-2': routeTmt2,
      'tmt-68': routeTmt68,
    };
    return uniqueRoutes.values.where((r) {
      final no = r.routeNumber.toLowerCase();
      final fullNo = '${r.operator.toLowerCase()} $no';
      final name = r.name.toLowerCase();
      final dest = r.destination.toLowerCase();
      final orig = r.origin.toLowerCase();
      final stopMatches = r.stops.any((s) => s.name.toLowerCase().contains(q));

      return no.contains(q) ||
          fullNo.contains(q) ||
          name.contains(q) ||
          dest.contains(q) ||
          orig.contains(q) ||
          stopMatches;
    }).toList();
  }

  /// Finds routes connecting two stop names (or containing both)
  static List<TransitRoute> findRoutesBetween(String fromStop, String toStop) {
    final fromQ = fromStop.toLowerCase().trim();
    final toQ = toStop.toLowerCase().trim();

    final all = [routeTmt65, routeTmt50, routeTmt2, routeTmt68];
    final matches = all.where((r) {
      final hasFrom = fromQ.isEmpty ||
          r.stops.any((s) => s.name.toLowerCase().contains(fromQ)) ||
          r.origin.toLowerCase().contains(fromQ);
      final hasTo = toQ.isEmpty ||
          r.stops.any((s) => s.name.toLowerCase().contains(toQ)) ||
          r.destination.toLowerCase().contains(toQ);
      return hasFrom && hasTo;
    }).toList();

    return matches.isNotEmpty ? matches : all;
  }

  /// Finds the nearest bus stop to a given GPS coordinate
  static NearestStopResult findNearestStop(double lat, double lon) {
    TransitStop nearest = allThaneStops.first;
    double minDistance = double.infinity;

    for (final stop in allThaneStops) {
      final distMeters = calculateDistanceMeters(lat, lon, stop.latitude, stop.longitude);
      if (distMeters < minDistance) {
        minDistance = distMeters;
        nearest = stop;
      }
    }

    return NearestStopResult(stop: nearest, distanceMeters: minDistance.round());
  }

  // -------------------------------------------------------------
  // Geospatial Math Utilities
  // -------------------------------------------------------------

  /// Calculates bearing between two coordinates in degrees (0-360)
  static double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double toRad(double deg) => (deg * math.pi) / 180;
    double toDeg(double rad) => (rad * 180) / math.pi;

    final dLon = toRad(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(toRad(lat2));
    final x = math.cos(toRad(lat1)) * math.sin(toRad(lat2)) -
        math.sin(toRad(lat1)) * math.cos(toRad(lat2)) * math.cos(dLon);

    final brng = toDeg(math.atan2(y, x));
    return (brng + 360) % 360;
  }

  /// Calculates approximate distance in km using the Haversine formula
  static double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0; // Earth's radius in km
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLon = (lon2 - lon1) * (math.pi / 180);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Calculates approximate distance in meters using Haversine formula
  static double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
    return calculateDistanceKm(lat1, lon1, lat2, lon2) * 1000.0;
  }
}

class NearestStopResult {
  final TransitStop stop;
  final int distanceMeters;

  const NearestStopResult({
    required this.stop,
    required this.distanceMeters,
  });
}

