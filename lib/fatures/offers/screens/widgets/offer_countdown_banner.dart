
// ============================================
// FILE: lib/fatures/offers/screens/widgets/offer_countdown_banner.dart
// ============================================

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

/// Maroon gradient banner with a live-ticking countdown to [endsAt].
/// Shows a "Days" segment only when more than a day remains.
class OfferCountdownBanner extends StatefulWidget {
  final String title;
  final DateTime endsAt;

  const OfferCountdownBanner({
    super.key,
    required this.title,
    required this.endsAt,
  });

  @override
  State<OfferCountdownBanner> createState() => _OfferCountdownBannerState();
}

class _OfferCountdownBannerState extends State<OfferCountdownBanner> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endsAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = widget.endsAt.difference(DateTime.now());
      if (!mounted) return;
      setState(() => _remaining = left.isNegative ? Duration.zero : left);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _remaining;
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingLarge,
        horizontal: AppDimensions.paddingMedium,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight.withOpacity(0.55),
            AppColors.primary,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (days > 0) ...[
                _Segment(value: days, label: AppStrings.daysLabel.tr()),
                const SizedBox(width: AppDimensions.paddingSmall),
              ],
              _Segment(value: hours, label: AppStrings.hoursLabel.tr()),
              const SizedBox(width: AppDimensions.paddingSmall),
              _Segment(value: minutes, label: AppStrings.minutesLabel.tr()),
              const SizedBox(width: AppDimensions.paddingSmall),
              _Segment(value: seconds, label: AppStrings.secondsLabel.tr()),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final int value;
  final String label;
  const _Segment({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppDimensions.fontSizeXLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: AppDimensions.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }
}
