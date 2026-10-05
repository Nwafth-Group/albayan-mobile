
// ============================================
// FILE: lib/fatures/favorites/screens/widgets/favorite_item_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';
import '../../data/models/favorite_item_model.dart';

/// One favorite (book, issue or article) — styled like the app's article
/// row card, with a filled heart that unfavorites it.
class FavoriteItemCard extends StatelessWidget {
  final FavoriteItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onUnfavorite;

  const FavoriteItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onUnfavorite,
  });

  String get _typeLabel {
    switch (item.type) {
      case FavoriteType.book:
        return AppStrings.cartTypeBook.tr();
      case FavoriteType.issue:
        return AppStrings.cartTypeIssue.tr();
      case FavoriteType.article:
        return AppStrings.cartTypeArticle.tr();
    }
  }

  String _money(num value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

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
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    child: SizedBox(
                      width: 96,
                      height: 128,
                      child: _Cover(url: item.image),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _typeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onUnfavorite,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        if (item.author.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        // Free items show no price line.
                        if (!item.isFree) ...[
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${_money(item.effectivePrice)} ',
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
                        if (item.rate > 0) ...[
                          const SizedBox(height: 4),
                          _StarRating(rating: item.rate),
                        ],
                        if (item.publishedAt != null)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              DateFormat('MMM d, yyyy')
                                  .format(item.publishedAt!),
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

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.menu_book_outlined,
          color: AppColors.textLight,
          size: 32,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : placeholder,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
