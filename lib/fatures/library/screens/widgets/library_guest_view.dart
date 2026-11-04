// ============================================
// FILE: lib/fatures/library/screens/widgets/library_guest_view.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/app_navigator.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/custom_button.dart';
import '../../../auth/screens/login_screen.dart';

/// Shown on the Library tabs to a guest — the library lives on the reader's
/// account, so instead of a request that would fail with 401 the guest is
/// asked to log in.
class LibraryGuestView extends StatelessWidget {
  final IconData icon;
  final String message;

  const LibraryGuestView({
    super.key,
    this.icon = Icons.local_library_outlined,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight.isFinite
                ? constraints.maxHeight - AppDimensions.paddingLarge * 2
                : 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.accentPale,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Text(
                AppStrings.guestModeTitle.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeXLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              SizedBox(
                width: 220,
                height: 48,
                child: CustomButton(
                  text: AppStrings.login.tr(),
                  onPressed: () => AppNavigator.push(const LoginScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
