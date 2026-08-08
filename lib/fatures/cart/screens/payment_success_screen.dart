
// ============================================
// FILE: lib/fatures/cart/screens/payment_success_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

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
