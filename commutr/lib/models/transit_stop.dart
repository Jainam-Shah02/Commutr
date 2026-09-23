/// Represents a physical public bus stop along a transit route
class TransitStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int order;
  final bool isMajor;

  const TransitStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
    this.isMajor = false,
  });

  factory TransitStop.fromJson(Map<String, dynamic> json) {
    return TransitStop(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      order: json['order'] as int,
      isMajor: json['isMajor'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'order': order,
        'isMajor': isMajor,
      };
}
