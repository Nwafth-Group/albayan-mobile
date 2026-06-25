// ============================================
// FILE: lib/fatures/articles/screens/widgets/about_article_tab.dart
// ============================================

import 'package:albayan/fatures/authors/screens/author_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/article_model.dart';

class AboutArticleTab extends StatelessWidget {
  final ArticleModel article;

  const AboutArticleTab({
    super.key,
    required this.article,
  });

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
        // Author
        if (author != null) ...[
          Text(
            AppStrings.author.tr(),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage:
                (author.image != null && author.image!.isNotEmpty)
                    ? NetworkImage(author.image!)
                    : null,
                child: (author.image == null || author.image!.isEmpty)
                    ? const Icon(Icons.person, color: AppColors.textLight)
                    : null,
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.displayName,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AuthorScreen(authorId: author.id),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppStrings.visit.tr(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: AppDimensions.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Overview
        if (article.summary != null && article.summary!.trim().isNotEmpty) ...[
          Text(
            AppStrings.overviewOfArticle.tr(),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            article.summary!,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Category / keywords
        if (article.keywords.isNotEmpty) ...[
          Text(
            AppStrings.category.tr(),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: [
              for (var i = 0; i < article.keywords.length; i++)
                _KeywordChip(
                  label: article.keywords[i].name,
                  highlighted: i == 0,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  const _KeywordChip({required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          color: highlighted ? AppColors.primary : AppColors.textSecondary,
          fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}