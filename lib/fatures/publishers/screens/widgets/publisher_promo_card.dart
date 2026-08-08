
// ============================================
// FILE: lib/fatures/publishers/screens/widgets/publisher_promo_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// "Discover books published by this house" promo banner — publisher logo
/// plus up to two book covers collaged on the right, with a Discover action
/// (typically scrolls down to the Related books section).
class PublisherPromoCard extends StatelessWidget {
  final String? logo;
  final List<String> bookCovers;
  final VoidCallback? onDiscover;

  const PublisherPromoCard({
    super.key,
    required this.logo,
    required this.bookCovers,
    this.onDiscover,
  });

  @override
  Widget build(BuildContext context) {
    final covers = bookCovers.take(2).toList();
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
                  AppStrings.discoverBooksTitle.tr(),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                GestureDetector(
                  onTap: onDiscover,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      AppStrings.discoverBtn.tr(),
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
            width: 100,
            height: 90,
            child: Stack(
              children: [
                if (logo != null && logo!.isNotEmpty)
                  Positioned(
                    left: 0,
                    top: 10,
                    child: ClipOval(
                      child: _thumb(logo, width: 48, height: 48),
                    ),
                  ),
                for (var i = 0; i < covers.length; i++)
                  Positioned(
                    right: i * 22,
                    top: 0,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                      child: _thumb(covers[i], width: 50, height: 76),
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
    return SizedBox(
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
    );
  }
}
