// ============================================
// FILE: lib/fatures/corners/screens/widgets/corner_article_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';
import '../../data/models/corner_article_model.dart';

class CornerArticleCard extends StatelessWidget {
  final CornerArticleModel article;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onCartTap;

  const CornerArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onFavoriteTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    child: SizedBox(
                      width: 96,
                      height: 128,
                      child: _CoverImage(url: article.image),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Issue label + action chips
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.issueLabel.tr(
                                  namedArgs: {
                                    'number': article.issueNumber.toString(),
                                  },
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (!article.isFree) ...[
                              _ActionChip(
                                onTap: onCartTap,
                                child: Image.asset(
                                  AppImages.cart,
                                  width: 13,
                                  height: 13,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 13,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            _ActionChip(
                              onTap: onFavoriteTap,
                              child: Icon(
                                article.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // Free articles show no price line.
                        if (!article.isFree) ...[
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${article.price.toStringAsFixed(2)} ',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: AppStrings.currencySar.tr(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                        const SizedBox(height: 4),
                        _StarRating(rating: article.rate),
                        if (article.publishedAt != null)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              DateFormat(
                                'MMM d, yyyy',
                              ).format(article.publishedAt!),
                              style: const TextStyle(
                                fontSize: AppDimensions.fontSizeSmall,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small round cream chip holding the cart / heart icon.
class _ActionChip extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _ActionChip({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.cardColor,
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (i < rating.floor()) {
          icon = Icons.star;
        } else if (i < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: Colors.amber, size: 11);
      }),
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
        child: Icon(
          Icons.menu_book_outlined,
          color: AppColors.textLight,
          size: 32,
        ),
      ),
    );
  }
}
