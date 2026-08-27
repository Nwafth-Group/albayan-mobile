
// ============================================
// FILE: lib/fatures/library/screens/widgets/library_issue_card.dart
// ============================================
//
// 2-column grid card for the Albayan Magazine "Issues" screen: cover with
// a delete badge, title, and the saved date.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';
import '../../data/models/library_issue_model.dart';
import 'library_delete_badge.dart';

class LibraryIssueCard extends StatelessWidget {
  final LibraryIssueModel issue;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const LibraryIssueCard({
    super.key,
    required this.issue,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    child: _Cover(url: issue.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: LibraryDeleteBadge(onTap: onDelete),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            issue.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM d, yyyy').format(issue.date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.menu_book_outlined,
            color: AppColors.textLight, size: 32),
      ),
    );
  }
}
