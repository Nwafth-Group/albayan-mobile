// ============================================
// FILE: lib/fatures/settings/screens/change_password_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/shared_pref_helper.dart';
import 'verification_code_screen.dart';
import 'widgets/settings_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.isEmpty)
      ? AppStrings.validationPasswordRequired.tr()
      : null;

  String? _newValidator(String? v) {
    final required = _required(v);
    if (required != null) return required;
    if (v!.length < 8) return AppStrings.validationPasswordMin.tr();
    return null;
  }

  String? _confirmValidator(String? v) {
    final required = _required(v);
    if (required != null) return required;
    if (v != _new.text) return AppStrings.validationPasswordMismatch.tr();
    return null;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // TODO(api): send current/new password to the change-password endpoint
    // (which sends the OTP) once it exists.
    AppNavigator.push(VerificationCodeScreen(target: _maskedTarget()));
  }

  /// "m********m@gmail.com" (or the masked phone number).
  String _maskedTarget() {
    final user = SharedPrefHelper.getUser();
    final email = user?.email;
    if (email != null && email.contains('@')) {
      final at = email.indexOf('@');
      final name = email.substring(0, at);
      if (name.length <= 2) return email;
      return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}'
          '${email.substring(at)}';
    }
    final phone = user?.mobileNumber ?? '';
    if (phone.length > 4) {
      return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(title: AppStrings.changePassword.tr()),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _PasswordField(
              label: AppStrings.currentPassword.tr(),
              hint: AppStrings.retypePasswordHint.tr(),
              controller: _current,
              validator: _required,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              label: AppStrings.newPassword.tr(),
              hint: AppStrings.newPasswordHint.tr(),
              controller: _new,
              validator: _newValidator,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              label: AppStrings.confirmNewPassword.tr(),
              hint: AppStrings.retypePasswordHint.tr(),
              controller: _confirm,
              validator: _confirmValidator,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SettingsBottomButton(
        text: AppStrings.btnSave.tr(),
        onPressed: _save,
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return SettingsField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscure,
      prefix: const Padding(
        padding: EdgeInsetsDirectional.only(start: 12, end: 8),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedSquareLock02,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      suffix: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: HugeIcon(
          icon: _obscure
              ? HugeIcons.strokeRoundedView
              : HugeIcons.strokeRoundedViewOff,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
    );
  }
}
