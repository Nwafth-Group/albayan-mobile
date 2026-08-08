
// ============================================
// FILE: lib/fatures/notifications/screens/notifications_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../data/models/notification_model.dart';
import '../data/notifications_mock_data.dart';
import 'widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // TODO: replace with a real cubit + datasource once a notifications
  // endpoint exists. For now the screen renders straight from mock data.
  static List<AppNotificationModel> _load() => mockNotifications();

  /// Groups notifications into "Today" / "Yesterday" / formatted-date
  /// sections, preserving each group's original (already sorted) order.
  Map<String, List<AppNotificationModel>> _grouped(BuildContext context) {
    final items = _load()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<AppNotificationModel>>{};
    for (final n in items) {
      final day = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      final String label;
      if (day == today) {
        label = AppStrings.today.tr();
      } else if (day == yesterday) {
        label = AppStrings.yesterday.tr();
      } else {
        label = DateFormat('MMM d, yyyy').format(day);
      }
      grouped.putIfAbsent(label, () => []).add(n);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: AppStrings.notificationsTitle.tr()),
      body: SafeArea(
        child: grouped.isEmpty
            ? EmptyStateWidget(
                image: AppImages.noData,
                message: AppStrings.noNotifications.tr(),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                children: [
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.paddingMedium,
                        bottom: AppDimensions.paddingSmall,
                      ),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeMedium,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    for (final n in entry.value)
                      NotificationTile(
                        notification: n,
                        onTap: () {
                          // TODO: navigate to the related item once
                          // notifications carry a real target reference.
                        },
                      ),
                  ],
                  const SizedBox(height: AppDimensions.paddingLarge),
                ],
              ),
      ),
    );
  }
}
