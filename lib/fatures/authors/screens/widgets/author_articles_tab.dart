
// ============================================
// FILE: lib/fatures/authors/screens/widgets/author_articles_tab.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import 'package:albayan/fatures/corners/screens/widgets/corner_article_card.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/empty_state_widget.dart';
import 'year_filter_chips.dart';

class AuthorArticlesTab extends StatelessWidget {
  final List<CornerArticleModel> items;
  final List<int> years;
  final int? selectedYear;
  final bool loadingMore;
  final ValueChanged<int> onYearSelected;
  final VoidCallback onLoadMore;
  final void Function(CornerArticleModel) onItemTap;

  const AuthorArticlesTab({
    super.key,
    required this.items,
    required this.years,
    required this.selectedYear,
    required this.loadingMore,
    required this.onYearSelected,
    required this.onLoadMore,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppDimensions.paddingSmall),
        YearFilterChips(
          years: years,
          selected: selectedYear,
          onSelected: onYearSelected,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Expanded(
          child: items.isEmpty
              ? EmptyStateWidget(
            image: AppImages.noData,
            message: AppStrings.noArticles.tr(),
          )
              : NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                onLoadMore();
              }
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.paddingLarge,
              ),
              children: [
                for (final a in items)
                  CornerArticleCard(
                    article: a,
                    onTap: () => onItemTap(a),
                  ),
                if (loadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingMedium),
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
          ),
        ),
      ],
    );
  }
}