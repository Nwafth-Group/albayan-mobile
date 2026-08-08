
// ============================================
// FILE: lib/fatures/notifications/data/notifications_mock_data.dart
// ============================================
//
// NOTE: No backend endpoint for notifications has been provided yet. This
// exists so the UI can be built and reviewed now. Once a real endpoint
// exists, replace this with a real datasource/cubit that parses JSON into
// `AppNotificationModel` — the screen and widgets don't depend on anything
// else here.

import 'models/notification_model.dart';

const _darwishCover =
    'http://18.192.211.42/storage/cover/BookVersion/6a3a7ac43562e_book1.jpg';
const _authorImage =
    'http://18.192.211.42/storage/avatar/Author/6a3a7ac3c0967_authors1.jpg';

List<AppNotificationModel> mockNotifications() {
  final now = DateTime.now();
  return [
    // Today
    AppNotificationModel(
      id: 'n1',
      title: 'New Book Added',
      image: _darwishCover,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    AppNotificationModel(
      id: 'n2',
      title: 'Mahmoud Darwish New Book Added',
      image: _authorImage,
      createdAt: now.subtract(const Duration(hours: 2, minutes: 10)),
    ),
    AppNotificationModel(
      id: 'n3',
      title: 'New Book Added',
      image: _darwishCover,
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
    // Yesterday
    AppNotificationModel(
      id: 'n4',
      title: 'New Book Added',
      image: _darwishCover,
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
    ),
    AppNotificationModel(
      id: 'n5',
      title: 'New Book Added',
      image: _darwishCover,
      createdAt: now.subtract(const Duration(days: 1, hours: 4)),
    ),
    AppNotificationModel(
      id: 'n6',
      title: 'Mahmoud Darwish New Book Added',
      image: _authorImage,
      createdAt: now.subtract(const Duration(days: 1, hours: 5)),
    ),
    AppNotificationModel(
      id: 'n7',
      title: 'Mahmoud Darwish New Book Added',
      image: _authorImage,
      createdAt: now.subtract(const Duration(days: 1, hours: 6)),
    ),
    AppNotificationModel(
      id: 'n8',
      title: 'New Book Added',
      image: _darwishCover,
      createdAt: now.subtract(const Duration(days: 1, hours: 8)),
    ),
  ];
}
