// ============================================
// FILE: lib/fatures/articles/screens/widgets/article_info_bar.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/article_model.dart';

/// Raised Rating | Language | Price card under the article hero.
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
        vertical: 14,
        horizontal: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
    );
  }

  Widget _divider() =>
      Container(width: 1.5, height: 34, color: AppColors.primary);

  static const _valueStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const _labelStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
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
            style: _valueStyle,
          ),
          const SizedBox(height: 4),
          Text(label, style: _labelStyle),
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
              style: _valueStyle.copyWith(color: AppColors.success),
            )
          else
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: article.price.toStringAsFixed(0),
                    style: _valueStyle,
                  ),
                  TextSpan(
                    text: AppStrings.currencySar.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(AppStrings.price.tr(), style: _labelStyle),
        ],
      ),
    );
  }
}
