// ============================================
// FILE: lib/fatures/articles/screens/widgets/about_article_tab.dart
// ============================================

import 'package:albayan/fatures/authors/screens/author_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/promo_banner.dart';
import '../../data/models/article_model.dart';

class AboutArticleTab extends StatelessWidget {
  final ArticleModel article;

  const AboutArticleTab({super.key, required this.article});

  static const _headingStyle = TextStyle(
    fontSize: AppDimensions.fontSizeLarge,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final author = article.author;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingLarge,
      ),
      children: [
        const AdPromoBanner(
          padding: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
        ),

        // Author
        if (author != null) ...[
          Text(AppStrings.author.tr(), style: _headingStyle),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage:
                    (author.image != null && author.image!.isNotEmpty)
                    ? NetworkImage(author.image!)
                    : null,
                child: (author.image == null || author.image!.isEmpty)
                    ? const Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.textLight,
                      )
                    : null,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.displayName,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AuthorScreen(authorId: author.id),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppStrings.visit.tr(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: AppDimensions.fontSizeMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        // Overview
        if (article.summary != null && article.summary!.trim().isNotEmpty) ...[
          Text(AppStrings.overviewOfArticle.tr(), style: _headingStyle),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            article.summary!,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Category / keywords
        if (article.keywords.isNotEmpty) ...[
          Text(AppStrings.category.tr(), style: _headingStyle),
          const SizedBox(height: 12),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: [
              for (final keyword in article.keywords)
                _KeywordChip(label: keyword.name),
            ],
          ),
        ],
      ],
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  const _KeywordChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13.5, color: AppColors.primary),
      ),
    );
  }
}
