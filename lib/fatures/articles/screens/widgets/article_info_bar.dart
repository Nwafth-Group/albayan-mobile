// ============================================
// FILE: lib/fatures/articles/screens/widgets/article_info_bar.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/article_model.dart';

class ArticleInfoBar extends StatelessWidget {
  final ArticleModel article;
  const ArticleInfoBar({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingMedium,
        horizontal: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.surface),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _textCell(article.rate.toStringAsFixed(1), AppStrings.rating.tr()),
            _divider(),
            _textCell(article.languageLabel, AppStrings.language.tr()),
            _divider(),
            _priceCell(),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(
    width: 1,
    thickness: 1,
    color: AppColors.primary,
    indent: 4,
    endIndent: 4,
  );

  Widget _textCell(String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCell() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (article.isFree)
            Text(
              AppStrings.free.tr(),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            )
          else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: article.price.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: AppStrings.currencySar.tr(),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeSmall,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            AppStrings.price.tr(),
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