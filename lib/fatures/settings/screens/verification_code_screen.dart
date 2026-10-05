// ============================================
// FILE: lib/fatures/settings/screens/verification_code_screen.dart
// ============================================

import 'dart:async';

import 'package:albayan/fatures/main/screens/main_screen.dart';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import 'widgets/settings_widgets.dart';

/// OTP step of Change Password — on success shows the "Success!" sheet.
class VerificationCodeScreen extends StatefulWidget {
  /// Masked email / phone the code was sent to.
  final String target;

  const VerificationCodeScreen({super.key, required this.target});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
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
    // TODO(api): call the change-password resend-OTP endpoint.
    _startTimer();
  }

  Future<void> _submit() async {
    if (_pin.text.length < 5) {
      Helpers.showError(AppStrings.validationOtpRequired.tr());
      return;
    }
    // TODO(api): verify `_pin.text` with the change-password endpoint and
    // only continue on success.
    final backHome = await showSettingsSheet(
      context,
      title: AppStrings.successExclaim.tr(),
      message: AppStrings.passwordChanged.tr(),
      primaryText: AppStrings.backToHome.tr(),
      isDismissible: false,
    );
    if (backHome == true) {
      AppNavigator.pushAndRemoveUntil(const MainScreen());
    }
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

    return Scaffold(
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
            AppStrings.codeSentPhone.tr(),
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
      bottomNavigationBar: SettingsBottomButton(
        text: AppStrings.btnSubmit.tr(),
        onPressed: _submit,
      ),
    );
  }
}
