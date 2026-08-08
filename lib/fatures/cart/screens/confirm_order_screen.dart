
// ============================================
// FILE: lib/fatures/cart/screens/confirm_order_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../data/models/cart_item_model.dart';
import 'payment_success_screen.dart';
import 'widgets/order_summary_card.dart';

class ConfirmOrderScreen extends StatelessWidget {
  final List<CartItemModel> items;
  final num subtotal;
  final double discountPercent;
  final num? promoDeduction;
  final num total;

  const ConfirmOrderScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.discountPercent,
    required this.promoDeduction,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
              child: Text(
                AppStrings.confirmYourOrder.tr(),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeXLarge,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMedium,
                  0,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingLarge,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.items.tr(),
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        for (final item in items) ...[
                          _ItemRow(item: item),
                          if (item != items.last)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingSmall,
                              ),
                              child: Divider(
                                  height: 1, color: AppColors.surfaceVariant),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingLarge),
                  OrderSummaryCard(
                    subtotal: subtotal,
                    taxes: 0,
                    discountPercent: discountPercent,
                    promoDeduction: promoDeduction,
                    total: total,
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
                      text: AppStrings.back.tr(),
                      isOutlined: true,
                      textColor: AppColors.primary,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: AppStrings.proceedToPayment.tr(),
                      onPressed: () {
                        // TODO: integrate a real payment gateway. For now
                        // this simulates a successful payment.
                        AppNavigator.push(const PaymentSuccessScreen());
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

class _ItemRow extends StatelessWidget {
  final CartItemModel item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: SizedBox(
            width: 76,
            height: 90,
            child: (item.image != null && item.image!.isNotEmpty)
                ? Image.network(
                    item.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.surfaceVariant),
                  )
                : const ColoredBox(color: AppColors.surfaceVariant),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.subLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeSmall,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeSmall,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _StarRow(rating: item.rate),
                  const Spacer(),
                  if (item.hasDiscount) ...[
                    Text(
                      item.oldPrice.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeSmall,
                        color: AppColors.textLight,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    '${item.newPrice.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (i < rating.floor()) {
          icon = Icons.star;
        } else if (i < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: Colors.amber, size: 12);
      }),
    );
  }
}
