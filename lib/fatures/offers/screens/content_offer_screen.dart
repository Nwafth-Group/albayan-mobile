
// ============================================
// FILE: lib/fatures/offers/screens/content_offer_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../articles/screens/widgets/star_row.dart';
import '../data/models/offer_model.dart';
import 'widgets/offer_countdown_banner.dart';

/// Shared offer landing page for [OfferType.book] and [OfferType.article]
/// offers — a simplified promotional view (cover + price + overview),
/// distinct from the full [BookScreen]/[ArticleScreen] which have tabs,
/// reviews, and related items.
class ContentOfferScreen extends StatelessWidget {
  final OfferModel offer;
  const ContentOfferScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final isBook = offer.type == OfferType.book;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: offer.name),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingSmall,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingLarge,
                ),
                children: [
                  OfferCountdownBanner(
                    title: AppStrings.offerEndsInDetail.tr(),
                    endsAt: offer.endsAt,
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                        child: SizedBox(
                          width: 130,
                          height: 190,
                          child: _Cover(url: offer.image),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${offer.discountPercent}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: AppDimensions.fontSizeSmall,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Text(
                              offer.name,
                              style: const TextStyle(
                                fontSize: AppDimensions.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            if (offer.author != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                offer.author!,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSizeSmall,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (isBook && offer.pagesCount != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.pagesLabel.tr(
                                  namedArgs: {
                                    'count': offer.pagesCount.toString()
                                  },
                                ),
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSizeSmall,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Row(
                              children: [
                                Text(
                                  '${offer.oldPrice.toStringAsFixed(0)} ${AppStrings.currencySar.tr()}',
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontSizeSmall,
                                    color: AppColors.textLight,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${offer.newPrice.toStringAsFixed(0)} ${AppStrings.currencySar.tr()}',
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontSizeMedium,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (offer.rate != null) ...[
                              const SizedBox(height: 4),
                              StarRow(rating: offer.rate!, size: 16),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  Text(
                    isBook
                        ? AppStrings.overviewOfBook.tr()
                        : AppStrings.overview.tr(),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  if (offer.overview != null)
                    Text(
                      offer.overview!,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: AppStrings.gift.tr(),
                      isOutlined: true,
                      textColor: AppColors.primary,
                      onPressed: () {
                        // TODO: gift flow
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: offer.isFree
                          ? AppStrings.addToCart.tr()
                          : '${AppStrings.addToCart.tr()} ${offer.newPrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
                      onPressed: () {
                        // TODO: add to cart
                      },
                    ),
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
        child: const Icon(Icons.menu_book_outlined,
            color: AppColors.textLight, size: 32),
      );
}
