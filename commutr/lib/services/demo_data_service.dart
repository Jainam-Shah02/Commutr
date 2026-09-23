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

  static final Map<String, TransitRoute> allRoutes = {
    'tmt-50': routeTmt50,
    'tmt50': routeTmt50,
    'tmt-2': routeTmt2,
    'tmt2': routeTmt2,
  };

  static List<AlertItem> initialAlerts = [
    AlertItem(
      id: 'alert-1',
      title: 'TMT 50 Approaching',
      message: 'Estimated arrival at Majiwada Junction in ~4 min. Verified by 6 passengers.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      type: AlertType.approach,
      routeNumber: '50',
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
}
