
// ============================================
// FILE: lib/fatures/offers/screens/issue_offer_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../cart/data/models/cart_item_model.dart';
import '../../cart/utils/add_to_cart_mixin.dart';
import '../data/models/offer_model.dart';
import 'cubit/offer_details_cubit.dart';
import 'widgets/offer_content_status.dart';
import 'widgets/offer_countdown_banner.dart';
import 'widgets/offer_format.dart';

class IssueOfferScreen extends StatelessWidget {
  final OfferModel offer;

  /// Already-loaded content; when null the issue's short word and index are
  /// fetched from `/public/issues/{id}`.
  final OfferContent? initialContent;

  const IssueOfferScreen({
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
      child: _IssueOfferView(offer: offer),
    );
  }
}

class _IssueOfferView extends StatefulWidget {
  final OfferModel offer;
  const _IssueOfferView({required this.offer});

  @override
  State<_IssueOfferView> createState() => _IssueOfferViewState();
}

class _IssueOfferViewState extends State<_IssueOfferView>
    with AddToCartStateMixin {
  int _tab = 0; // 0 = Short Word, 1 = Issue Index

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final state = context.watch<OfferDetailsCubit>().state;
    final content = state.content;

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
                          height: 150,
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
                              ),
                            ),
                            if (content.publishedAt != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                DateFormat('MMM d, yyyy')
                                    .format(content.publishedAt!),
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSizeSmall,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _tabs(),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  _tab == 0
                      ? _shortWord(offer, state)
                      : _issueIndex(state),
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
                        onPressed: () {
                          // TODO: gift flow
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMedium),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text:
                            '${AppStrings.addToCart.tr()} ${offerMoney(offer.newPrice)} ${AppStrings.currencySar.tr()}',
                        isLoading: isAddingToCart,
                        onPressed: () => addToCart(
                          type: CartItemType.issue,
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

  Widget _tabs() {
    return Row(
      children: [
        _TabItem(
          label: AppStrings.shortWord.tr(),
          selected: _tab == 0,
          onTap: () => setState(() => _tab = 0),
        ),
        const SizedBox(width: AppDimensions.paddingLarge),
        _TabItem(
          label: AppStrings.issueIndex.tr(),
          selected: _tab == 1,
          onTap: () => setState(() => _tab = 1),
        ),
      ],
    );
  }

  Widget _shortWord(OfferModel offer, OfferDetailsState state) {
    final content = state.content;
    final summary = content.shortWordSummary;
    if (summary == null || summary.trim().isEmpty) {
      return OfferContentStatus(
        loading: state.isLoading,
        failed: state.isFailure,
        onRetry: () => context.read<OfferDetailsCubit>().load(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                content.shortWordTitle ?? offer.name,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              AppStrings.editorialStaff.tr(),
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeSmall,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Text(
          summary,
          style: const TextStyle(
            fontSize: AppDimensions.fontSizeMedium,
            height: 1.7,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _issueIndex(OfferDetailsState state) {
    final items = state.content.indexItems;
    if (items.isEmpty) {
      if (state.isLoading || state.isFailure) {
        return OfferContentStatus(
          loading: state.isLoading,
          failed: state.isFailure,
          onRetry: () => context.read<OfferDetailsCubit>().load(),
        );
      }
      return Center(
        child: Text(
          AppStrings.noResults.tr(),
          style: const TextStyle(color: AppColors.textLight),
        ),
      );
    }
    return Column(
      children: [
        for (final item in items) ...[
          _IndexTile(item: item),
          const SizedBox(height: AppDimensions.paddingMedium),
        ],
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: selected ? AppColors.textPrimary : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2.5,
            width: 36,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexTile extends StatelessWidget {
  final OfferIndexItem item;
  const _IndexTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
              width: 72,
              height: 72,
              child: _Cover(url: item.image),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titleAr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        child: const Icon(Icons.image_outlined,
            color: AppColors.textLight, size: 24),
      );
}
