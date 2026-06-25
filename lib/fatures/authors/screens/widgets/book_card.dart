
// ============================================
// FILE: lib/fatures/authors/screens/widgets/book_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onCartTap;

  const BookCard({
    super.key,
    required this.book,
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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: SizedBox(
                  width: 84,
                  height: 104,
                  child: _Cover(url: book.image),
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
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppDimensions.fontSizeSmall,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (!book.isFree)
                          _Mini(icon: Icons.shopping_cart_outlined, onTap: onCartTap),
                        _Mini(
                          icon: book.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: book.isFavorite
                              ? AppColors.error
                              : AppColors.primary,
                          onTap: onFavoriteTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _PriceRow(book: book),
                    const SizedBox(height: 5),
                    _StarRow(rating: book.rate),
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

class _PriceRow extends StatelessWidget {
  final BookModel book;
  const _PriceRow({required this.book});

  @override
  Widget build(BuildContext context) {
    if (book.isFree) {
      return Text(
        AppStrings.free.tr(),
        style: const TextStyle(
          fontSize: AppDimensions.fontSizeSmall,
          fontWeight: FontWeight.w700,
          color: AppColors.success,
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${book.effectivePrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
          style: const TextStyle(
            fontSize: AppDimensions.fontSizeSmall,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (book.hasDiscount) ...[
          const SizedBox(width: 6),
          Text(
            book.price.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              color: AppColors.textLight,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _Mini({required this.icon, this.color = AppColors.primary, this.onTap});

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
    return Image.network(url!, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph());
  }

  Widget _ph() => Container(
    color: AppColors.surfaceVariant,
    child: const Icon(Icons.menu_book_outlined,
        color: AppColors.textLight, size: 28),
  );
}