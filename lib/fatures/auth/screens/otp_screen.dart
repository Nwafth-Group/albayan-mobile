// ============================================
// FILE: lib/fatures/auth/screens/otp_screen.dart
// ============================================

import 'dart:async';
import 'package:albayan/fatures/auth/screens/success_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';

class OtpScreen extends StatefulWidget {
  final String recipient; // email or phone
  final bool isEmail;

  const OtpScreen({
    Key? key,
    required this.recipient,
    required this.isEmail,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _focusNode     = FocusNode();
  bool _isLoading = false;
  bool _hasError  = false;

  // Resend countdown
  static const int _resendSeconds = 57;
  int _secondsLeft = _resendSeconds;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _resendOtp() {
    if (_secondsLeft > 0) return;
    _timer.cancel();
    _pinController.clear();
    setState(() => _hasError = false);
    // TODO: trigger resend via cubit
    _startTimer();
  }

  String get _maskedRecipient {
    if (widget.isEmail) {
      final parts = widget.recipient.split('@');
      if (parts.length != 2) return widget.recipient;
      final name   = parts[0];
      final domain = parts[1];
      final masked = name.length <= 2
          ? name
          : '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
      return '$masked@$domain';
    } else {
      if (widget.recipient.length < 5) return widget.recipient;
      return '${widget.recipient.substring(0, 3)}****'
          '${widget.recipient.substring(widget.recipient.length - 3)}';
    }
  }

  void _onSubmit() {
    if (_pinController.text.length < 5) {
      setState(() => _hasError = true);
      return;
    }
    setState(() {
      _isLoading = true;
      _hasError  = false;
    });

    // TODO: dispatch verify cubit event
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SuccessDialog(),
    );
  }

  // Called by our custom numpad
  void _onNumpadTap(String digit) {
    if (_pinController.text.length >= 5) return;
    _pinController.text = _pinController.text + digit;
    setState(() => _hasError = false);
    if (_pinController.text.length == 5) _onSubmit();
  }

  void _onBackspace() {
    if (_pinController.text.isEmpty) return;
    _pinController.text =
        _pinController.text.substring(0, _pinController.text.length - 1);
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Pinput themes ────────────────────────────────────────
    final defaultTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 2),
    );

    final submittedTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 1.5),
      color: AppColors.cardColor,
    );

    final errorTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: AppColors.error, width: 1.5),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Scrollable content ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      AppStrings.otpTitle.tr(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                              text: '${AppStrings.otpSubtitle.tr()} '),
                          TextSpan(
                            text: _maskedRecipient,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const TextSpan(
                              text:
                              ' and completely verify your account.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Pinput field ──────────────────────────
                    Pinput(
                      length: 5,
                      controller: _pinController,
                      focusNode: _focusNode,
                      // Disable system keyboard — driven by our numpad
                      keyboardType: TextInputType.none,
                      defaultPinTheme: defaultTheme,
                      focusedPinTheme: focusedTheme,
                      submittedPinTheme: submittedTheme,
                      errorPinTheme: errorTheme,
                      forceErrorState: _hasError,
                      showCursor: true,
                      cursor: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            width: 20,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      onChanged: (_) => setState(() => _hasError = false),
                      onCompleted: (_) => _onSubmit(),
                    ),

                    // Error text
                    if (_hasError) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.validationOtpRequired.tr(),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.error),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Resend ────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Text(
                            AppStrings.otpCodeSent.tr(),
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _resendOtp,
                            child: Text(
                              _secondsLeft > 0
                                  ? '${AppStrings.otpResend.tr()} ${_formatTime(_secondsLeft)}'
                                  : AppStrings.otpResendNow.tr(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _secondsLeft > 0
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Submit button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: CustomButton(
                        text: AppStrings.btnSubmit.tr(),
                        isLoading: _isLoading,
                        onPressed: _onSubmit,
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Custom numpad pinned to bottom ────────────────
            _CustomNumpad(
              onTap: _onNumpadTap,
              onBackspace: _onBackspace,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ─────────────────────────────────────────────────────────────
// Custom Numpad
// ─────────────────────────────────────────────────────────────
class _CustomNumpad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onBackspace;

  const _CustomNumpad({required this.onTap, required this.onBackspace});

  static const List<List<String>> _rows = [
    ['1', '', '2', 'ABC', '3', 'DEF'],
    ['4', 'GHI', '5', 'JKL', '6', 'MNO'],
    ['7', 'PQRS', '8', 'TUV', '9', 'WXYZ'],
    ['', '', '0', '', 'back', ''],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: _rows.map((row) {
          final cells = <Widget>[];
          for (int i = 0; i < row.length; i += 2) {
            final main = row[i];
            final sub  = row[i + 1];

            if (main == 'back') {
              cells.add(Expanded(
                child: _NumKey(
                  onTap: onBackspace,
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ));
            } else if (main.isEmpty) {
              cells.add(const Expanded(child: SizedBox()));
            } else {
              cells.add(Expanded(
                child: _NumKey(
                  onTap: () => onTap(main),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        main,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (sub.isNotEmpty)
                        Text(
                          sub,
                          style: const TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ));
            }
          }
          return Row(children: cells);
        }).toList(),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _NumKey({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 68,
        child: Center(child: child),
      ),
    );
  }
}