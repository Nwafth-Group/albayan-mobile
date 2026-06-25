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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingxSmall,
      ),
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail (unchanged size)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: SizedBox(
                  width: 96,
                  height: 120,
                  child: _CoverImage(url: article.image),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: issue label + action icons
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.issueLabel.tr(
                              namedArgs: {
                                'number': article.issueNumber.toString(),
                              },
                            ),
                            style: const TextStyle(
                              fontSize: AppDimensions.fontSizeSmall,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!article.isFree)
                          _IconButtonSmall(
                            icon: Icons.shopping_cart_outlined,
                            onTap: onCartTap,
                          ),
                        _IconButtonSmall(
                          icon: article.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: article.isFavorite
                              ? AppColors.error
                              : AppColors.primary,
                          onTap: onFavoriteTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Title
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Author
                    Text(
                      article.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Price (or Free)
                    _PriceLabel(price: article.price, isFree: article.isFree),
                    const SizedBox(height: 5),
                    // Rating + date
                    Row(
                      children: [
                        _StarRating(rating: article.rate),
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
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  final num price;
  final bool isFree;
  const _PriceLabel({required this.price, required this.isFree});

  @override
  Widget build(BuildContext context) {
    if (isFree) {
      return Text(
        AppStrings.free.tr(),
        style: const TextStyle(
          fontSize: AppDimensions.fontSizeSmall,
          fontWeight: FontWeight.w700,
          color: AppColors.success,
        ),
      );
    }
    return Text(
      '${price.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
      style: const TextStyle(
        fontSize: AppDimensions.fontSizeSmall,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}

class _IconButtonSmall extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _IconButtonSmall({
    required this.icon,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final int total;
  const _StarRating({required this.rating, this.total = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        IconData icon;
        if (i < rating.floor()) {
          icon = Icons.star;
        } else if (i < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: Colors.amber, size: 12);
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
        child: Icon(Icons.menu_book_outlined,
            color: AppColors.textLight, size: 32),
      ),
    );
  }
}