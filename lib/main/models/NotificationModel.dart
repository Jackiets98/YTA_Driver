class NotificationData {
  final String id;
  final String driver;
  final String notificationText;
  final String createdAt;
  final String? updatedAt;

  NotificationData({
    required this.id,
    required this.driver,
    required this.notificationText,
    required this.createdAt,
    this.updatedAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'],
      driver: json['driver'],
      notificationText: json['notification_text'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

