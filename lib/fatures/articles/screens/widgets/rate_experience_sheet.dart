
// ============================================
// FILE: lib/fatures/articles/screens/widgets/rate_experience_sheet.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/custom_button.dart';

class RateExperienceResult {
  final double rating;
  final String? comment;
  const RateExperienceResult(this.rating, this.comment);
}

/// Shows the rating sheet. Returns a [RateExperienceResult] when the user
/// taps Send Feedback, or `null` if cancelled/dismissed.
Future<RateExperienceResult?> showRateExperienceSheet(BuildContext context) {
  return showModalBottomSheet<RateExperienceResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RateExperienceSheet(),
  );
}

class _RateExperienceSheet extends StatefulWidget {
  const _RateExperienceSheet();

  @override
  State<_RateExperienceSheet> createState() => _RateExperienceSheetState();
}

class _RateExperienceSheetState extends State<_RateExperienceSheet> {
  int _rating = 0;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingLarge,
        right: AppDimensions.paddingLarge,
        top: AppDimensions.paddingMedium,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppDimensions.paddingLarge,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            AppStrings.rateYourExperience.tr(),
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            AppStrings.rateExperienceDesc.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          // Star selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return IconButton(
                onPressed: () => setState(() => _rating = i + 1),
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          // Feedback text
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: AppStrings.tellUs.tr(),
              hintStyle: const TextStyle(color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: AppStrings.cancel.tr(),
                  isOutlined: true,
                  textColor: AppColors.primary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: CustomButton(
                  text: AppStrings.sendFeedback.tr(),
                  onPressed: _rating == 0
                      ? null
                      : () => Navigator.of(context).pop(
                    RateExperienceResult(
                      _rating.toDouble(),
                      _controller.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}