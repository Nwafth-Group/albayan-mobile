
// ============================================
// FILE: lib/fatures/articles/screens/widgets/similar_article_card.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:albayan/fatures/corners/data/models/corner_article_model.dart';
import '../../../../utils/constants.dart';
import 'star_row.dart';

class SimilarArticleCard extends StatelessWidget {
  final CornerArticleModel article;
  final VoidCallback? onTap;
  const SimilarArticleCard({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              child: SizedBox(
                width: 64,
                height: 64,
                child: _Cover(url: article.image),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${article.author} , ${article.issueNumber.toString().padLeft(4, '0')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeSmall,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StarRow(rating: article.rate, size: 12),
                      const Spacer(),
                      if (article.publishedAt != null)
                        Text(
                          DateFormat('MMM d, yyyy')
                              .format(article.publishedAt!),
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSizeSmall,
                            color: AppColors.textLight,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _ph();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ph(),
    );
  }

  Widget _ph() => Container(
    color: AppColors.surfaceVariant,
    child: const Icon(Icons.menu_book_outlined,
        color: AppColors.textLight, size: 24),
  );
}