
// ============================================
// FILE: lib/fatures/issues/screens/widgets/index_article_tile.dart
// ============================================

import 'package:albayan/fatures/issues/data/models/issue_detail_model.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

class IndexArticleTile extends StatelessWidget {
  final IndexPreviewItem item;
  final VoidCallback? onTap;

  const IndexArticleTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final corner = item.corner?.name ?? '';
    final title = item.article?.title ?? '';
    final author = item.author?.displayName ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _ArticleImage(url: item.article?.image),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (corner.isNotEmpty)
                    Text(
                      corner,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (author.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  final String? url;
  const _ArticleImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: AppColors.surfaceVariant);
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.surfaceVariant,
    child: const Icon(Icons.image_outlined,
        color: AppColors.textLight, size: 24),
  );
}