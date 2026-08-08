
// ============================================
// FILE: lib/fatures/offers/screens/package_offer_screen.dart
// ============================================

import 'package:albayan/fatures/authors/data/models/book_model.dart';
import 'package:albayan/fatures/books/screens/widgets/book_grid_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../data/models/offer_model.dart';
import 'widgets/offer_countdown_banner.dart';

class PackageOfferScreen extends StatelessWidget {
  final OfferModel offer;
  const PackageOfferScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      Text(
                        '${offer.oldPrice.toStringAsFixed(0)} ${AppStrings.currencySar.tr()}',
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeLarge,
                          color: AppColors.textLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Text(
                        '${offer.newPrice.toStringAsFixed(0)} ${AppStrings.currencySar.tr()}',
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Text(
                    AppStrings.itemsIncludedInPackage.tr(),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppDimensions.paddingMedium,
                      crossAxisSpacing: AppDimensions.paddingMedium,
                      childAspectRatio: 0.52,
                    ),
                    itemCount: offer.packageItems.length,
                    itemBuilder: (context, index) {
                      final item = offer.packageItems[index];
                      return BookGridCard(
                        book: BookModel(
                          id: item.id,
                          bookId: item.id,
                          name: item.title,
                          language: '',
                          image: item.image,
                          author: item.author,
                          price: item.price,
                          finalPrice: null,
                          rate: item.rate,
                          rateCount: 0,
                          isFavorite: false,
                        ),
                        onTap: () {
                          // TODO: open the real book once package items are
                          // backed by real book ids.
                        },
                        onCartTap: () {},
                      );
                    },
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
                      text: AppStrings.addToCart.tr(),
                      onPressed: () {
                        // TODO: add package to cart
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
