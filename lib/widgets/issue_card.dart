// ============================================
// FILE: lib/fatures/issues/screens/widgets/issue_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';
import '../fatures/issues/data/models/issue_model.dart';

class IssueCard extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback? onTap;

  const IssueCard({super.key, required this.issue, this.onTap});

  String get _dateText {
    if (issue.publishedAt == null) return '';
    return DateFormat('MMM d, yyyy', 'en').format(issue.publishedAt!);
  }

  String get _priceText => issue.price.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image fills the leftover vertical space so the card never overflows.
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: SizedBox(
                width: double.infinity,
                child: _CoverImage(url: issue.coverImage),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            issue.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _dateText,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          if (issue.isFree)
            Text(
              AppStrings.free.tr(),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            )
          else
            Row(
              children: [
                Text(
                  _priceText,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  AppStrings.currencySar.tr(),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;
  const _CoverImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.menu_book_outlined,
            color: AppColors.textLight, size: 36),
      ),
    );
  }
}