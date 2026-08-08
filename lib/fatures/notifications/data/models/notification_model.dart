
// ============================================
// FILE: lib/fatures/notifications/data/models/notification_model.dart
// ============================================

class AppNotificationModel {
  final String id;
  final String title;
  final String? image;
  final DateTime createdAt;
  final bool read;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    this.read = true,
  });
}
