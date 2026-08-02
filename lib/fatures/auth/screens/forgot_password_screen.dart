// ============================================
// FILE: lib/fatures/auth/screens/forgot_password_screen.dart
// ============================================

import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'forgot_password_otp_screen.dart';

// ─────────────────────────────────────────────────────────────
// Entry point — provides its own AuthCubit
// ─────────────────────────────────────────────────────────────
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRemoteDataSource(ApiService())),
      child: const _ForgotPasswordBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────
class _ForgotPasswordBody extends StatefulWidget {
  const _ForgotPasswordBody();

  @override
  State<_ForgotPasswordBody> createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<_ForgotPasswordBody> {
  final _formKey          = GlobalKey<FormState>();
  final _emailController  = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().forgotPassword(
      email: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordOtpSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthCubit>(),
                child: ForgotPasswordOtpScreen(email: state.email),
              ),
            ),
          );
        } else if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
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
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (_, s) =>
                    s is ForgotPasswordLoading ||
                        s is ForgotPasswordOtpSent ||
                        s is ForgotPasswordError,
                    builder: (context, state) => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: CustomButton(
                        text: AppStrings.btnContinue.tr(),
                        isLoading: state is ForgotPasswordLoading,
                        onPressed: _onContinue,
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}