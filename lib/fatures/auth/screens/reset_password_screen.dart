
// ============================================
// FILE: lib/fatures/auth/screens/reset_password_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_navigator.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_form_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey               = GlobalKey<FormState>();
  final _passwordController    = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    // TODO: dispatch reset password cubit event
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Go all the way back to login
      AppNavigator.popToRoot();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Title ─────────────────────────────────────
                Text(
                  AppStrings.resetPasswordTitle.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Subtitle ──────────────────────────────────
                Text(
                  AppStrings.resetPasswordSubtitle.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Password label ────────────────────────────
                Text(
                  AppStrings.labelPassword.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Password field ────────────────────────────
                CustomTextField(
                  controller: _passwordController,
                  hintText: AppStrings.hintPassword.tr(),
                  obscureText: _obscurePassword,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.lock_outline_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textLight,
                        size: 22,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.validationPasswordRequired.tr();
                    }
                    if (v.length < 8) {
                      return AppStrings.validationPasswordMin.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Confirm password label ────────────────────
                Text(
                  AppStrings.labelConfirmPassword.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Confirm password field ────────────────────
                CustomTextField(
                  controller: _confirmPassController,
                  hintText: AppStrings.hintConfirmPassword.tr(),
                  obscureText: _obscureConfirm,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.lock_outline_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textLight,
                        size: 22,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.validationConfirmPasswordRequired
                          .tr();
                    }
                    if (v != _passwordController.text) {
                      return AppStrings.validationPasswordMismatch.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // ── Save button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomButton(
                    text: AppStrings.btnSave.tr(),
                    isLoading: _isLoading,
                    onPressed: _onSave,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}