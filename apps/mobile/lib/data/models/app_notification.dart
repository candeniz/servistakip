import '../../core/constants/statuses.dart';

/// Uygulama bildirimi.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.readAt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        type: NotificationType.fromValue(json['type'] as String? ?? 'announcement'),
        readAt: json['read_at'] == null ? null : DateTime.tryParse(json['read_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
