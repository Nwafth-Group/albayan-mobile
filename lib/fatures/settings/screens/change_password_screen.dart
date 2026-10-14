// ============================================
// FILE: lib/fatures/settings/screens/change_password_screen.dart
// ============================================

import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:albayan/fatures/main/screens/main_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import 'widgets/settings_widgets.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRemoteDataSource(ApiService())),
      child: const _ChangePasswordBody(),
    );
  }
}

class _ChangePasswordBody extends StatefulWidget {
  const _ChangePasswordBody();

  @override
  State<_ChangePasswordBody> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<_ChangePasswordBody> {
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
    context.read<AuthCubit>().changePassword(
      currentPassword: _current.text,
      newPassword: _new.text,
      newPasswordConfirmation: _confirm.text,
    );
  }

  Future<void> _onSuccess() async {
    final backHome = await showSettingsSheet(
      context,
      title: AppStrings.successExclaim.tr(),
      message: AppStrings.passwordChanged.tr(),
      primaryText: AppStrings.backToHome.tr(),
      isDismissible: false,
    );
    if (backHome == true && mounted) {
      AppNavigator.pushAndRemoveUntil(const MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          _onSuccess();
        } else if (state is ChangePasswordError) {
          Helpers.showError(state.message);
        }
      },
      child: Scaffold(
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
        bottomNavigationBar: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (_, s) =>
              s is ChangePasswordLoading ||
              s is ChangePasswordSuccess ||
              s is ChangePasswordError,
          builder: (context, state) => SettingsBottomButton(
            text: AppStrings.btnSave.tr(),
            isLoading: state is ChangePasswordLoading,
            onPressed: _save,
          ),
        ),
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
