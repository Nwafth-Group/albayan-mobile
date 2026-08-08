
// ============================================
// FILE: lib/fatures/cart/screens/widgets/cart_item_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/cart_item_model.dart';

/// Cart row with swipe-to-remove (swipe from the right, matching the
/// trash-can reveal in the mockup).
class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;

  const CartItemCard({super.key, required this.item, required this.onRemove});

  String get _typeLabel {
    switch (item.type) {
      case CartItemType.book:
        return AppStrings.cartTypeBook.tr();
      case CartItemType.article:
        return AppStrings.cartTypeArticle.tr();
      case CartItemType.issue:
        return AppStrings.cartTypeIssue.tr();
      case CartItemType.package:
        return AppStrings.cartTypePackage.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingxSmall,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingxSmall,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
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
                width: 76,
                height: 90,
                child: _Cover(url: item.image),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.subLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSizeSmall,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _typeLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppDimensions.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
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
                  Text(
                    item.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeSmall,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StarRow(rating: item.rate),
                      const Spacer(),
                      if (item.hasDiscount) ...[
                        Text(
                          item.oldPrice.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSizeSmall,
                            color: AppColors.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '${item.newPrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeMedium,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
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

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

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
        return Icon(icon, color: Colors.amber, size: 12);
      }),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _ph();
    return Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
  }

  Widget _ph() => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.image_outlined,
            color: AppColors.textLight, size: 28),
      );
}
