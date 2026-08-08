
// ============================================
// FILE: lib/fatures/cart/screens/widgets/order_summary_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

class OrderSummaryCard extends StatelessWidget {
  final num subtotal;
  final num taxes;
  final double discountPercent;
  final num? promoDeduction;
  final num total;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.taxes,
    required this.discountPercent,
    required this.promoDeduction,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.orderSummary.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _row(AppStrings.totalAmount.tr(),
              '${subtotal.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}'),
          const SizedBox(height: AppDimensions.paddingSmall),
          _row(AppStrings.taxes.tr(),
              '${taxes.toStringAsFixed(0)} ${AppStrings.currencySar.tr()}'),
          const SizedBox(height: AppDimensions.paddingSmall),
          _row(AppStrings.discount.tr(), '${discountPercent.round()}%'),
          const SizedBox(height: AppDimensions.paddingSmall),
          _row(
            AppStrings.promoCode.tr(),
            promoDeduction != null && promoDeduction! > 0
                ? '-${promoDeduction!.toStringAsFixed(2)}'
                : '-',
            valueColor: promoDeduction != null && promoDeduction! > 0
                ? AppColors.primary
                : AppColors.textLight,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          const _DashedDivider(),
          const SizedBox(height: AppDimensions.paddingMedium),
          _row(
            AppStrings.totalAmount.tr(),
            '${total.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) {
    final style = TextStyle(
      fontSize: AppDimensions.fontSizeMedium,
      fontWeight: bold ? FontWeight.bold : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(color: AppColors.textSecondary)),
        Text(value, style: style.copyWith(color: valueColor ?? style.color)),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / 8).floor();
          return Row(
            children: List.generate(
              count,
              (_) => Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  color: AppColors.surfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
