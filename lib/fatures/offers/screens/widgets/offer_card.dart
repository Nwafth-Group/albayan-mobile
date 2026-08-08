
// ============================================
// FILE: lib/fatures/offers/screens/widgets/offer_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants.dart';
import '../../data/models/offer_model.dart';

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
                    ? _PackageTile(percent: offer.discountPercent)
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
                      _Badge(percent: offer.discountPercent),
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
                          fontSize: AppDimensions.fontSizeSmall,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (offer.type == OfferType.package &&
                      offer.booksCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${offer.booksCount} ${AppStrings.booksTab.tr()}',
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
                      DateFormat('MMM d, yyyy').format(offer.date),
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
  final int percent;
  const _Badge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percent%',
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
  final int percent;
  const _PackageTile({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: AppColors.accentPale,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percent%',
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            'OFF',
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
