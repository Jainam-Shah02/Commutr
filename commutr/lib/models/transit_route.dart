import 'transit_stop.dart';

class TimetableTimeSlot {
  final String time;
  final String status; // 'LIVE' | 'SCHEDULED'

  const TimetableTimeSlot({
    required this.time,
    required this.status,
  });
}

class TimetableEntry {
  final String period; // 'morning' | 'afternoon' | 'evening'
  final List<TimetableTimeSlot> times;

  const TimetableEntry({
    required this.period,
    required this.times,
  });
}

/// Geographic coordinate pair [latitude, longitude]
class GeoCoord {
  final double latitude;
  final double longitude;

  const GeoCoord(this.latitude, this.longitude);

  List<double> toList() => [latitude, longitude];
}

/// High-fidelity Transit Route with road polylines and detour paths
class TransitRoute {
  final String id;
  final String operator;
  final String routeNumber;
  final String name;
  final String origin;
  final String destination;
  final String direction; // 'outbound' | 'inbound'
  final List<TransitStop> stops;
  final List<GeoCoord> coordinates;
  final List<GeoCoord>? detourCoordinates;
  final List<TimetableEntry> timetable;

  const TransitRoute({
    required this.id,
    required this.operator,
    required this.routeNumber,
    required this.name,
    required this.origin,
    required this.destination,
    required this.direction,
    required this.stops,
    required this.coordinates,
    this.detourCoordinates,
    this.timetable = const [],
  });
}
