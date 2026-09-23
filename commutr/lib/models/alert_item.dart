enum AlertType {
  disruption,
  detour,
  approach,
  arrival,
  info,
}

/// Passenger transit alert item
class AlertItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final AlertType type;
  final String routeNumber;
  final bool isUnread;

  const AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.routeNumber,
    this.isUnread = false,
  });
}
