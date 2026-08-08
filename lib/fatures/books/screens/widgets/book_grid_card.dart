// ============================================
// FILE: lib/fatures/books/screens/widgets/book_grid_card.dart
// ============================================

import 'package:albayan/fatures/articles/screens/widgets/star_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../../authors/data/models/book_model.dart';

/// 2-column grid card for the books list / related books screens.
/// Cover image with a small cart icon overlaid top-right, title, author,
/// price (with a struck-through original price when discounted), and a
/// star rating row.
class BookGridCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final VoidCallback? onCartTap;

  const BookGridCard({
    super.key,
    required this.book,
    this.onTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.95,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
                    child: _Cover(url: book.image),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _CartBadge(onTap: onCartTap),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            book.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          _PriceRow(book: book),
          const SizedBox(height: 3),
          StarRow(rating: book.rate, size: 13),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final BookModel book;
  const _PriceRow({required this.book});

  @override
  Widget build(BuildContext context) {
    if (book.isFree) {
      return Text(
        AppStrings.free.tr(),
        style: const TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.w700,
          color: AppColors.success,
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (book.hasDiscount) ...[
          Text(
            book.price.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textLight,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          '${book.effectivePrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
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

class _CartBadge extends StatelessWidget {
  final VoidCallback? onTap;
  const _CartBadge({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          size: 16,
          color: AppColors.primary,
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