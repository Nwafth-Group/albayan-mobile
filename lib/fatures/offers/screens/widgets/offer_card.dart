
// ============================================
// FILE: lib/fatures/offers/screens/widgets/offer_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/offer_model.dart';
import 'offer_format.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback? onTap;

  const OfferCard({super.key, required this.offer, this.onTap});

  String get _typeLabel {
    switch (offer.type) {
      case OfferType.package:
        return AppStrings.offerPackage.tr();
      case OfferType.book:
        return AppStrings.offerBook.tr();
      case OfferType.issue:
        return AppStrings.offerIssue.tr();
      case OfferType.article:
        return AppStrings.offerArticle.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
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
                width: 84,
                height: 90,
                child: offer.type == OfferType.package
                    ? _PackageTile(label: offerDiscountLabel(offer))
                    : _CoverImage(url: offer.image),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _typeLabel,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSizeMedium,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      _Badge(label: offerDiscountLabel(offer)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
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
                          fontSize: AppDimensions.fontSizeSmall,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  // `extra_info` for a package is its books count, already
                  // localized by the backend ("3 Books").
                  if (offer.type == OfferType.package &&
                      (offer.extraInfo?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 2),
                    Text(
                      offer.extraInfo!,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      offer.endDateLabel,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textLight,
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

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppDimensions.fontSizeSmall,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  final String label;
  const _PackageTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: AppColors.accentPale,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            AppStrings.offerOff.tr(),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSmall,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;
  const _CoverImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _ph();
    return Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
  }

  Widget _ph() => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.local_offer_outlined,
            color: AppColors.textLight, size: 28),
      );
}
