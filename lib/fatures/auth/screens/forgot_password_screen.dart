
// ============================================
// FILE: lib/fatures/auth/screens/forgot_password_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_navigator.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _emailController  = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    // TODO: dispatch forgot password cubit event
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppNavigator.push(const ResetPasswordScreen());
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
                  AppStrings.forgotPasswordTitle.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Subtitle ──────────────────────────────────
                Text(
                  AppStrings.forgotPasswordSubtitle.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Email label ───────────────────────────────
                Text(
                  AppStrings.labelEmail.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Email field ───────────────────────────────
                CustomTextField(
                  controller: _emailController,
                  hintText: AppStrings.hintEmail.tr(),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.mail_outline_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.validationEmailRequired.tr();
                    }
                    if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(v)) {
                      return AppStrings.validationEmailInvalid.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ── Continue button ───────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomButton(
                    text: AppStrings.btnContinue.tr(),
                    isLoading: _isLoading,
                    onPressed: _onContinue,
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