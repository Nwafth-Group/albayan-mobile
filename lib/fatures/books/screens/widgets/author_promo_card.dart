
// ============================================
// FILE: lib/fatures/books/screens/widgets/author_promo_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// "Discover the author behind this book" promo banner shown under the
/// About Book tab — cover thumbnail + author avatar with a Buy Now action.
class AuthorPromoCard extends StatelessWidget {
  final String? bookCover;
  final String? authorImage;
  final VoidCallback? onBuyNow;

  const AuthorPromoCard({
    super.key,
    required this.bookCover,
    required this.authorImage,
    this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.discoverAuthorTitle.tr(),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                GestureDetector(
                  onTap: onBuyNow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      AppStrings.buyNow.tr(),
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
          const SizedBox(width: AppDimensions.paddingSmall),
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 6,
                  child: _thumb(bookCover, width: 50, height: 74),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: ClipOval(
                    child: _thumb(authorImage, width: 44, height: 44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(String? url, {required double width, required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: SizedBox(
        width: width,
        height: height,
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: AppColors.surfaceVariant),
              )
            : const ColoredBox(color: AppColors.surfaceVariant),
      ),
    );
  }
}
