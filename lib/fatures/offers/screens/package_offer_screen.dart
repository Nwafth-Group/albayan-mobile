
// ============================================
// FILE: lib/fatures/offers/screens/package_offer_screen.dart
// ============================================

import 'package:albayan/fatures/books/screens/widgets/book_grid_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../books/screens/book_screen.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../../cart/utils/add_to_cart_mixin.dart';
import '../data/models/offer_model.dart';
import 'cubit/offer_details_cubit.dart';
import 'widgets/offer_content_status.dart';
import 'widgets/offer_countdown_banner.dart';
import 'widgets/offer_format.dart';

class PackageOfferScreen extends StatelessWidget {
  final OfferModel offer;

  /// Already-loaded content (a campaign from `/public/offers/{id}`); when
  /// null the package's books are fetched.
  final OfferContent? initialContent;

  const PackageOfferScreen({
    super.key,
    required this.offer,
    this.initialContent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OfferDetailsCubit.create(offer, initialContent: initialContent)
            ..load(),
      child: _PackageOfferView(offer: offer),
    );
  }
}

class _PackageOfferView extends StatefulWidget {
  final OfferModel offer;
  const _PackageOfferView({required this.offer});

  @override
  State<_PackageOfferView> createState() => _PackageOfferViewState();
}

class _PackageOfferViewState extends State<_PackageOfferView>
    with AddToCartStateMixin {
  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final state = context.watch<OfferDetailsCubit>().state;
    final content = state.content;
    final items = content.packageItems;

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
                  // Only list items opened from the urgent offer know their
                  // exact end time; a countdown to a guessed time would lie.
                  if (content.endsAt != null) ...[
                    OfferCountdownBanner(
                      title: AppStrings.offerEndsInDetail.tr(),
                      endsAt: content.endsAt!,
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),
                  ],
                  Row(
                    children: [
                      Text(
                        '${offerMoney(offer.oldPrice)} ${AppStrings.currencySar.tr()}',
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeLarge,
                          color: AppColors.textLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Text(
                        '${offerMoney(offer.newPrice)} ${AppStrings.currencySar.tr()}',
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
                  if (items.isEmpty)
                    OfferContentStatus(
                      loading: state.isLoading,
                      failed: state.isFailure,
                      onRetry: () => context.read<OfferDetailsCubit>().load(),
                    )
                  else
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
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final book = items[index];
                        return BookGridCard(
                          book: book,
                          onTap: () =>
                              AppNavigator.push(BookScreen(bookId: book.id)),
                          onCartTap: () => addToCart(
                            type: CartItemType.book,
                            id: book.id,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            // A campaign's id is an offer id, not a package id, so it can't
            // be added to the cart as a whole — its books can, from the grid.
            if (!offer.isCampaign)
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
                        isLoading: isAddingToCart,
                        onPressed: () => addToCart(
                          type: CartItemType.package,
                          id: offer.id,
                        ),
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
