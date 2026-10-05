// ============================================
// FILE: lib/fatures/cart/screens/widgets/order_summary_card.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../data/models/cart_model.dart';
import '../../utils/cart_format.dart';

/// The `summary` block of `GET /reader/cart` — all amounts come straight
/// from the API (nothing is recalculated on the client).
class OrderSummaryCard extends StatelessWidget {
  final CartSummaryModel summary;

  const OrderSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currency = summary.currency;
    final taxRate = summary.taxRate;
    final taxLabel = taxRate > 0
        ? '${AppStrings.taxes.tr()} (${taxRate % 1 == 0 ? taxRate.toInt() : taxRate}%)'
        : AppStrings.taxes.tr();

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
          _row(AppStrings.subtotal.tr(), cartMoney(summary.subtotal, currency)),
          const SizedBox(height: AppDimensions.paddingSmall),
          _discountRow(
            AppStrings.discount.tr(),
            summary.offerDiscount,
            currency,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _discountRow(
            AppStrings.promoCode.tr(),
            summary.couponDiscount,
            currency,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _row(taxLabel, cartMoney(summary.taxAmount, currency)),
          const SizedBox(height: AppDimensions.paddingMedium),
          const _DashedDivider(),
          const SizedBox(height: AppDimensions.paddingMedium),
          _row(
            AppStrings.totalAmount.tr(),
            cartMoney(summary.totalAmount, currency),
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _discountRow(String label, num amount, String? currency) {
    final has = amount > 0;
    return _row(
      label,
      has ? '-${cartMoney(amount, currency)}' : '-',
      valueColor: has ? AppColors.primary : AppColors.textLight,
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
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
