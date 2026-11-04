// ============================================
// FILE: lib/fatures/settings/screens/verification_code_screen.dart
// ============================================

import 'dart:async';
import 'dart:ui' as ui;

import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import 'widgets/settings_widgets.dart';

/// OTP step after changing the email on the Profile screen.
/// Pops `true` once the new email is verified.
class VerificationCodeScreen extends StatelessWidget {
  /// Email the code was sent to.
  final String target;

  const VerificationCodeScreen({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRemoteDataSource(ApiService())),
      child: _VerificationCodeBody(target: target),
    );
  }
}

class _VerificationCodeBody extends StatefulWidget {
  final String target;

  const _VerificationCodeBody({required this.target});

  @override
  State<_VerificationCodeBody> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<_VerificationCodeBody> {
  static const _resendSeconds = 60;

  final _pin = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    super.dispose();
  }

  void _resend() {
    context.read<AuthCubit>().resendProfileEmailOtp();
  }

  void _submit() {
    if (_pin.text.length < 5) {
      Helpers.showError(AppStrings.validationOtpRequired.tr());
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().verifyProfileEmail(otpCode: _pin.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = PinTheme(
      width: 54,
      height: 54,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: settingsBorder),
      ),
    );

    final mm = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ProfileEmailVerified) {
          Helpers.showSuccess(context, AppStrings.emailVerified.tr());
          AppNavigator.pop(true);
        } else if (state is ProfileEmailVerifyError) {
          _pin.clear();
        } else if (state is OtpResendSuccess) {
          Helpers.showSuccess(context, AppStrings.otpResentSuccess.tr());
          _startTimer();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: SettingsAppBar(title: AppStrings.verificationCode.tr()),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              AppStrings.otpSentTo.tr(namedArgs: {'target': widget.target}),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Pinput(
                length: 5,
                controller: _pin,
                autofocus: true,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                defaultPinTheme: theme,
                focusedPinTheme: theme.copyDecorationWith(
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
                submittedPinTheme: theme.copyDecorationWith(
                  border: Border.all(color: settingsBorder),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.codeSentEmail.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: _secondsLeft > 0
                  ? Text(
                      AppStrings.resendIn.tr(namedArgs: {'time': '$mm:$ss'}),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : GestureDetector(
                      onTap: _resend,
                      child: Text(
                        AppStrings.otpResendNow.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (_, s) =>
              s is ProfileEmailVerifyLoading ||
              s is ProfileEmailVerified ||
              s is ProfileEmailVerifyError,
          builder: (context, state) => SettingsBottomButton(
            text: AppStrings.btnSubmit.tr(),
            isLoading: state is ProfileEmailVerifyLoading,
            onPressed: state is ProfileEmailVerifyLoading ? null : _submit,
          ),
        ),
      ),
    );
  }
}
