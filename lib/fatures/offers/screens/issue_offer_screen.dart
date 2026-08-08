
// ============================================
// FILE: lib/fatures/offers/screens/issue_offer_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../data/models/offer_model.dart';
import 'widgets/offer_countdown_banner.dart';

class IssueOfferScreen extends StatefulWidget {
  final OfferModel offer;
  const IssueOfferScreen({super.key, required this.offer});

  @override
  State<IssueOfferScreen> createState() => _IssueOfferScreenState();
}

class _IssueOfferScreenState extends State<IssueOfferScreen> {
  int _tab = 0; // 0 = Short Word, 1 = Issue Index

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
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
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('MMM d, yyyy').format(offer.date),
                              style: const TextStyle(
                                fontSize: AppDimensions.fontSizeSmall,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${offer.newPrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
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
                  _tab == 0 ? _shortWord(offer) : _issueIndex(offer),
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
                      text:
                          '${AppStrings.addToCart.tr()} ${offer.newPrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
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

  Widget _shortWord(OfferModel offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                offer.shortWordTitle ?? offer.name,
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
          offer.shortWordSummary ?? '',
          style: const TextStyle(
            fontSize: AppDimensions.fontSizeMedium,
            height: 1.7,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _issueIndex(OfferModel offer) {
    if (offer.indexItems.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noResults.tr(),
          style: const TextStyle(color: AppColors.textLight),
        ),
      );
    }
    return Column(
      children: [
        for (final item in offer.indexItems) ...[
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
