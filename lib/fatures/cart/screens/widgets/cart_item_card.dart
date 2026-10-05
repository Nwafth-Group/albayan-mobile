// ============================================
// FILE: lib/fatures/cart/screens/widgets/cart_item_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/app_navigator.dart';
import '../../../../utils/constants.dart';
import '../../../articles/screens/article_screen.dart';
import '../../../books/screens/book_screen.dart';
import '../../../issues/screens/issue_details_screen.dart';
import '../../data/models/cart_item_model.dart';
import '../../utils/cart_format.dart';

/// Opens the book / issue / article a cart row points at (`item_id`).
/// Packages have no id-only detail screen, so they aren't tappable.
void openCartItem(CartItemModel item) {
  if (item.itemId.isEmpty) return;
  switch (item.type) {
    case CartItemType.book:
      AppNavigator.push(BookScreen(bookId: item.itemId));
      break;
    case CartItemType.issue:
      AppNavigator.push(IssueDetailsScreen(issueId: item.itemId));
      break;
    case CartItemType.article:
      AppNavigator.push(ArticleScreen(articleId: item.itemId));
      break;
    case CartItemType.package:
      break;
  }
}

/// Cart row with swipe-to-remove (swipe from the right, matching the
/// trash-can reveal in the mockup).
class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;

  /// The cart's `summary.currency`.
  final String? currency;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    this.currency,
  });

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
      child: GestureDetector(
        onTap: () => openCartItem(item),
        behavior: HitTestBehavior.opaque,
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
                  child: _Cover(url: item.image, type: item.type),
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
                        if (item.isGift) ...[
                          const CartGiftBadge(),
                          const SizedBox(width: 4),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
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
                    if (item.hasAuthor) ...[
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
                    ],
                    const SizedBox(height: 6),
                    CartItemPrice(item: item, currency: currency),
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

/// Final price, with the original struck through when an offer applies.
class CartItemPrice extends StatelessWidget {
  final CartItemModel item;
  final String? currency;

  const CartItemPrice({super.key, required this.item, this.currency});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (item.hasDiscount) ...[
          Text(
            item.oldPrice.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textLight,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          cartMoney(item.newPrice, currency),
          style: const TextStyle(
            fontSize: AppDimensions.fontSizeMedium,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

/// Small "Gift" pill for items bought as a gift (`is_gift`).
class CartGiftBadge extends StatelessWidget {
  const CartGiftBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentPale,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.card_giftcard, size: 12, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            AppStrings.gift.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppDimensions.fontSizeSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  final CartItemType type;
  const _Cover({this.url, required this.type});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _ph();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ph(),
    );
  }

  /// `image_url` is often null — show an icon for the item's type instead.
  Widget _ph() => Container(
    color: AppColors.surfaceVariant,
    child: Icon(cartTypeIcon(type), color: AppColors.textLight, size: 28),
  );
}

IconData cartTypeIcon(CartItemType type) {
  switch (type) {
    case CartItemType.book:
      return Icons.menu_book_outlined;
    case CartItemType.issue:
      return Icons.auto_stories_outlined;
    case CartItemType.article:
      return Icons.article_outlined;
    case CartItemType.package:
      return Icons.inventory_2_outlined;
  }
}
