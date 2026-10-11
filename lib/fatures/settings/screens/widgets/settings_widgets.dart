// ============================================
// FILE: lib/fatures/settings/screens/widgets/settings_widgets.dart
// ============================================
//
// Small building blocks shared by every settings sub-screen: the page app
// bar, the labelled input field, the confirm/message bottom sheet and the
// order status badge.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../utils/app_navigator.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/custom_button.dart';
import '../../data/models/order_model.dart';

/// Border colour of the settings inputs / cards in the designs.
const Color settingsBorder = Color(0xFFF1DCD3);

/// "← Title" app bar used by every settings page.
class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool showBack;
  final bool centerTitle;

  const SettingsAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
    this.showBack = true,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: showBack ? 0 : AppDimensions.paddingMedium,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: onBack ?? () => AppNavigator.pop(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: centerTitle,
      actions: [...actions, const SizedBox(width: 8)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Label above a rounded, peach-bordered input — the field style used in
/// Profile, Change Password, Redeem Gift and Contact Us.
class SettingsField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color fillColor;

  const SettingsField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.borderColor,
    this.fillColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
            filled: true,
            fillColor: fillColor,
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: border(borderColor ?? settingsBorder),
            focusedBorder: border(AppColors.primary, 1.2),
            errorBorder: border(AppColors.error),
            focusedErrorBorder: border(AppColors.error, 1.2),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet with a grabber, title, message, divider and one or two
/// buttons — Restore Purchases, Logout, password-changed and
/// thanks-for-feedback all use this.
///
/// Returns true when the primary button is tapped.
Future<bool?> showSettingsSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String primaryText,
  String? secondaryText,
  Color titleColor = AppColors.textPrimary,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontSizeLarge,
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: settingsBorder),
            const SizedBox(height: 18),
            Row(
              children: [
                if (secondaryText != null) ...[
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: CustomButton(
                        text: secondaryText,
                        isOutlined: true,
                        textColor: AppColors.primary,
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: CustomButton(
                      text: primaryText,
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Full-width primary button pinned to the bottom of a page.
class SettingsBottomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SettingsBottomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: CustomButton(
            text: text,
            isLoading: isLoading,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

/// Two side-by-side buttons (outlined + filled) pinned to the bottom.
class SettingsButtonPair extends StatelessWidget {
  final String secondaryText;
  final String primaryText;
  final VoidCallback? onSecondary;
  final VoidCallback? onPrimary;
  final bool isLoading;

  const SettingsButtonPair({
    super.key,
    required this.secondaryText,
    required this.primaryText,
    this.onSecondary,
    this.onPrimary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: CustomButton(
                  text: secondaryText,
                  isOutlined: true,
                  textColor: AppColors.primary,
                  onPressed: onSecondary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: CustomButton(
                  text: primaryText,
                  isLoading: isLoading,
                  onPressed: onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Completed / Processing / Cancelled pill.
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      OrderStatus.completed => (
        AppStrings.statusCompleted.tr(),
        const Color(0xFF3FA564),
        const Color(0xFFDDF3E4),
      ),
      OrderStatus.processing => (
        AppStrings.statusProcessing.tr(),
        const Color(0xFF3BB8B0),
        const Color(0xFFDDF4F2),
      ),
      OrderStatus.cancelled => (
        AppStrings.statusCancelled.tr(),
        AppColors.primary,
        AppColors.accentPale,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}

/// Soft white card used across the settings pages.
BoxDecoration settingsCard({double radius = 14}) => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ],
);

/// "35.09 SAR"
String settingsMoney(num amount) =>
    '${amount.toStringAsFixed(2)} ${AppStrings.currencySar.tr()}';
