
// ============================================
// FILE: lib/fatures/offers/screens/content_offer_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../articles/screens/widgets/star_row.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../../cart/utils/add_to_cart_mixin.dart';
import '../data/models/offer_model.dart';
import 'cubit/offer_details_cubit.dart';
import 'widgets/offer_content_status.dart';
import 'widgets/offer_countdown_banner.dart';
import 'widgets/offer_format.dart';

/// Shared offer landing page for [OfferType.book] and [OfferType.article]
/// offers — a simplified promotional view (cover + price + overview),
/// distinct from the full [BookScreen]/[ArticleScreen] which have tabs,
/// reviews, and related items.
class ContentOfferScreen extends StatelessWidget {
  final OfferModel offer;

  /// Already-loaded content; when null the author, pages, rating and
  /// overview are fetched from the book's / article's own endpoint.
  final OfferContent? initialContent;

  const ContentOfferScreen({
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
      child: _ContentOfferView(offer: offer),
    );
  }
}

class _ContentOfferView extends StatefulWidget {
  final OfferModel offer;
  const _ContentOfferView({required this.offer});

  @override
  State<_ContentOfferView> createState() => _ContentOfferViewState();
}

class _ContentOfferViewState extends State<_ContentOfferView>
    with AddToCartStateMixin {
  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final isBook = offer.type == OfferType.book;
    final state = context.watch<OfferDetailsCubit>().state;
    final content = state.content;
    final overview = content.overview;

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
                  // Only shown when the exact end time is known (see
                  // OfferContent.endsAt).
                  if (content.endsAt != null) ...[
                    OfferCountdownBanner(
                      title: AppStrings.offerEndsInDetail.tr(),
                      endsAt: content.endsAt!,
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),
                  ],
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
                                offerDiscountLabel(offer),
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
                            if (content.author?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 6),
                              Text(
                                content.author!,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSizeSmall,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (isBook && content.pagesCount != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.pagesLabel.tr(
                                  namedArgs: {
                                    'count': content.pagesCount.toString()
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
                                  '${offerMoney(offer.oldPrice)} ${AppStrings.currencySar.tr()}',
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontSizeSmall,
                                    color: AppColors.textLight,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${offerMoney(offer.newPrice)} ${AppStrings.currencySar.tr()}',
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontSizeMedium,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (content.rate != null) ...[
                              const SizedBox(height: 4),
                              StarRow(rating: content.rate!, size: 16),
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
                  if (overview != null && overview.trim().isNotEmpty)
                    Text(
                      overview,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    )
                  else
                    OfferContentStatus(
                      loading: state.isLoading,
                      failed: state.isFailure,
                      onRetry: () => context.read<OfferDetailsCubit>().load(),
                    ),
                ],
              ),
            ),
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
                        isLoading: isAddingGift,
                        onPressed: () => addGiftToCart(
                          type: isBook
                              ? CartItemType.book
                              : CartItemType.article,
                          id: offer.id,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: offer.isFree
                            ? AppStrings.addToCart.tr()
                            : '${AppStrings.addToCart.tr()} ${offerMoney(offer.newPrice)} ${AppStrings.currencySar.tr()}',
                        isLoading: isAddingToCart,
                        onPressed: () => addToCart(
                          type: isBook
                              ? CartItemType.book
                              : CartItemType.article,
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
