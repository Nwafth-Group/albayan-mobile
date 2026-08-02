
// ============================================
// FILE: lib/fatures/auth/screens/success_dialog.dart
// ============================================

import 'package:albayan/fatures/main/screens/main_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_navigator.dart';
import '../../../widgets/custom_button.dart';

class SuccessDialog extends StatelessWidget {
  final VoidCallback? onDone;

  const SuccessDialog({Key? key, this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Illustration ───────────────────────────────────
            _SuccessIllustration(),
            const SizedBox(height: 28),

            // ── Title ──────────────────────────────────────────
            Text(
              AppStrings.successTitle.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // ── Subtitle ───────────────────────────────────────
            Text(
              AppStrings.successSubtitle.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // ── Done Button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                text: AppStrings.btnDone.tr(),
                onPressed: () {
                  if (onDone != null) {
                    onDone!();
                  } else {
                    AppNavigator.pushAndRemoveUntil(const MainScreen());
                  }
                },
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Success Illustration (drawn with CustomPainter as a fallback
// – swap Image.asset(AppImages.successIllustration) when ready)
// ─────────────────────────────────────────────────────────────
class _SuccessIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Try loading the asset first; fall back to the drawn version
    return Image.asset(
      AppImages.successIllustration,
      // height: 160,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const _DrawnSuccess(),
    );
  }
}

class _DrawnSuccess extends StatelessWidget {
  const _DrawnSuccess();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pale circle
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPale,
            ),
          ),
          // Inner primary circle
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
          // Decorative dots
          Positioned(
            top: 12,
            right: 20,
            child: _Dot(size: 10, color: AppColors.accent),
          ),
          Positioned(
            top: 28,
            left: 18,
            child: _Dot(size: 6, color: AppColors.primaryLight),
          ),
          Positioned(
            bottom: 20,
            right: 14,
            child: _Dot(size: 8, color: AppColors.primaryLight),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;
  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}