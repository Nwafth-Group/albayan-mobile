// ============================================
// FILE: lib/fatures/cart/screens/payment_success_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../data/models/checkout_order_model.dart';
import '../utils/cart_format.dart';

class PaymentSuccessScreen extends StatelessWidget {
  /// The order returned by `POST /reader/cart/checkout`.
  final CheckoutOrderModel order;

  const PaymentSuccessScreen({super.key, required this.order});

  List<(String, String)> get _details {
    final invoiceNumber = order.invoice?.invoiceNumber ?? '';
    final reference =
        order.paymentReference ?? order.invoice?.paymentReference ?? '';
    return [
      if (order.orderNumber.isNotEmpty)
        (AppStrings.orderNumber.tr(), order.orderNumber),
      if (invoiceNumber.isNotEmpty)
        (AppStrings.invoiceNumber.tr(), invoiceNumber),
      if (reference.isNotEmpty) (AppStrings.paymentReference.tr(), reference),
      if (order.id.isNotEmpty)
        (
          AppStrings.totalAmount.tr(),
          cartMoney(order.summary.totalAmount, order.summary.currency),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Icon(
                Icons.check_circle_outline,
                size: 160,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Text(
                AppStrings.paymentSuccessful.tr(),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                AppStrings.paymentSuccessDesc.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_details.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingLarge),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                  child: Column(
                    children: [
                      for (final (label, value) in _details)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSizeMedium,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingSmall),
                              Expanded(
                                child: SelectableText(
                                  value,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontSizeMedium,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: AppStrings.back.tr(),
                      isOutlined: true,
                      textColor: AppColors.primary,
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: CustomButton(
                      text: AppStrings.viewOrder.tr(),
                      onPressed: () {
                        // TODO: navigate to a real order-details/library
                        // screen once orders are backed by a real API.
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: AppStrings.downloadInvoice.tr(),
                  backgroundColor: AppColors.surfaceVariant,
                  textColor: AppColors.primary,
                  onPressed: () {
                    // TODO: generate/download the invoice once a backend
                    // endpoint provides it.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
