
// ============================================
// FILE: lib/fatures/cart/screens/widgets/promo_code_field.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

class PromoCodeField extends StatelessWidget {
  final TextEditingController controller;
  final bool applied;
  final String? errorText;
  final VoidCallback onApply;

  const PromoCodeField({
    super.key,
    required this.controller,
    required this.applied,
    required this.errorText,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor =
        hasError ? AppColors.error : (applied ? AppColors.success : AppColors.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !applied,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeMedium,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: AppStrings.applyPromoCodeHint.tr(),
                    hintStyle: const TextStyle(color: AppColors.textLight),
                  ),
                ),
              ),
              if (applied)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.applied.tr(),
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  ],
                )
              else
                InkWell(
                  onTap: onApply,
                  child: Text(
                    AppStrings.apply.tr(),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMedium,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppDimensions.paddingxSmall),
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
