
// ============================================
// FILE: lib/fatures/offers/screens/widgets/offer_content_status.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// Fills an offer page's content area while it has nothing to show yet: a
/// spinner while loading, a retry link if the request failed, else nothing.
class OfferContentStatus extends StatelessWidget {
  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  const OfferContentStatus({
    super.key,
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
    if (failed) {
      return Center(
        child: TextButton(
          onPressed: onRetry,
          child: Text(
            '${AppStrings.somethingWentWrong.tr()} · ${AppStrings.retry.tr()}',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
