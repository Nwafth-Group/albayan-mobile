
// ============================================
// FILE: lib/fatures/articles/screens/widgets/reviews_tab.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../data/models/article_model.dart';
import '../../data/models/comment_model.dart';
import 'review_card.dart';
import 'star_row.dart';

class ReviewsTab extends StatelessWidget {
  final ArticleModel article;
  final List<CommentModel> comments;
  final bool loadingMore;
  final VoidCallback onLoadMore;

  const ReviewsTab({
    super.key,
    required this.article,
    required this.comments,
    required this.loadingMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return EmptyStateWidget(
        image: AppImages.noData,
        message: AppStrings.noReviews.tr(),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingMedium,
          AppDimensions.paddingMedium,
          AppDimensions.paddingMedium,
          AppDimensions.paddingLarge,
        ),
        children: [
          // Summary
          Row(
            children: [
              Text(
                article.rate.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              StarRow(rating: article.rate, size: 20),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            AppStrings.basedOnRatings.tr(
              namedArgs: {'count': article.rateCount.toString()},
            ),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Review list
          for (final c in comments) ReviewCard(comment: c),

          if (loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}