
// ============================================
// FILE: lib/fatures/articles/screens/widgets/similar_tab.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/empty_state_widget.dart';
import 'similar_article_card.dart';

class SimilarTab extends StatelessWidget {
  final List<CornerArticleModel> items;
  final bool loadingMore;
  final VoidCallback onLoadMore;
  final void Function(CornerArticleModel) onItemTap;

  const SimilarTab({
    super.key,
    required this.items,
    required this.loadingMore,
    required this.onLoadMore,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        image: AppImages.noData,
        message: AppStrings.noArticles.tr(),
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
          for (final a in items)
            SimilarArticleCard(article: a, onTap: () => onItemTap(a)),
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