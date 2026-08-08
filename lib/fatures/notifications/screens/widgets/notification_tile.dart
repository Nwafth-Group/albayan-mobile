
// ============================================
// FILE: lib/fatures/notifications/screens/widgets/notification_tile.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  String _timeAgo() {
    final diff = DateTime.now().difference(notification.createdAt);
    final hours = diff.inHours < 1 ? 1 : diff.inHours;
    return AppStrings.hoursAgo.tr(namedArgs: {'count': hours.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: (notification.image != null &&
                          notification.image!.isNotEmpty)
                      ? NetworkImage(notification.image!)
                      : null,
                  child: (notification.image == null ||
                          notification.image!.isEmpty)
                      ? const Icon(Icons.notifications_outlined,
                          color: AppColors.textLight)
                      : null,
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeAgo(),
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeSmall,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            const Divider(height: 1, color: AppColors.surfaceVariant),
          ],
        ),
      ),
    );
  }
}
