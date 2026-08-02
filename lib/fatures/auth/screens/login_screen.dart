// ============================================
// FILE: lib/fatures/auth/screens/login_screen.dart
// ============================================

import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/data/models/country_model.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:albayan/fatures/auth/screens/forgot_password_screen.dart';
import 'package:albayan/fatures/auth/screens/otp_screen.dart';
import 'package:albayan/fatures/auth/screens/register_screen.dart';
import 'package:albayan/fatures/main/screens/main_screen.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_form_field.dart';

// ─────────────────────────────────────────────────────────────
// Entry point — provides AuthCubit
// ─────────────────────────────────────────────────────────────
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRemoteDataSource(ApiService()))
        ..fetchCountries(),
      child: const _LoginBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────
class _LoginBody extends StatefulWidget {
  const _LoginBody();

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  final _formKey             = GlobalKey<FormState>();
  final _emailController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _phoneController     = TextEditingController();

  CountryModel? _selectedCountry;
  bool _rememberMe      = false;
  bool _obscurePassword = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _animCtrl.forward(from: 0);
  }

  void _onLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cubit = context.read<AuthCubit>();

    if (_selectedTab == 0) {
      cubit.loginWithEmail(
        email:    _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      // Combine country code + number, e.g. "+962" + "790404479" = "+962790404479"
      final code   = _selectedCountry?.phoneCode ?? '';
      final number = _phoneController.text.trim();
      cubit.loginWithMobile(
        mobileNumber: '$code$number',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Auto-select Saudi Arabia once countries load
        if (state is CountriesLoaded && _selectedCountry == null) {
          final saudi = state.countries.firstWhere(
                (c) => c.nameEn.toLowerCase().contains('saudi'),
            orElse: () => state.countries.first,
          );
          setState(() => _selectedCountry = saudi);
        }

        if (state is LoginSuccess) {
          AppNavigator.pushAndRemoveUntil(const MainScreen());
        } else if (state is LoginOtpRequired) {
          // Mobile login needs OTP verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthCubit>(),
                child: OtpScreen(
                  recipient: state.mobileNumber,
                  isEmail:   false,
                ),
              ),
            ),
          );
        } else if (state is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      AppImages.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const _LogoPlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab switcher
                  _TabSwitcher(selected: _selectedTab, onTap: _switchTab),
                  const SizedBox(height: 24),

                  // Heading
                  Text(AppStrings.loginTitle.tr(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(AppStrings.loginSubtitle.tr(),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),

                  // Animated form
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: _selectedTab == 0
                        ? _EmailForm(
                      emailController:    _emailController,
                      passwordController: _passwordController,
                      obscurePassword:    _obscurePassword,
                      rememberMe:         _rememberMe,
                      onTogglePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                      onRememberMe: (v) =>
                          setState(() => _rememberMe = v ?? false),
                      onForgotPassword: () => AppNavigator.push(
                          const ForgotPasswordScreen()),
                    )
                        : _PhoneForm(
                      phoneController:  _phoneController,
                      selectedCountry:  _selectedCountry,
                      onCountryChanged: (c) =>
                          setState(() => _selectedCountry = c),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (_, s) =>
                    s is LoginLoading ||
                        s is LoginSuccess ||
                        s is LoginError,
                    builder: (context, state) => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: CustomButton(
                        text: AppStrings.btnLogin.tr(),
                        isLoading: state is LoginLoading,
                        onPressed: _onLogin,
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Divider
                  _OrDivider(label: AppStrings.orContinueWith.tr()),
                  const SizedBox(height: 20),

                  // Social buttons
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: Image.asset(AppImages.appleIcon,
                              height: 22, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.apple, size: 22)),
                          label: AppStrings.continueWithApple.tr(),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SocialButton(
                          icon: Image.asset(AppImages.googleIcon,
                              height: 22, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.g_mobiledata, size: 22)),
                          label: AppStrings.continueWithGoogle.tr(),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Guest button
                  _GuestButton(onTap: () => AppNavigator.pushAndRemoveUntil(const MainScreen())),
                  const SizedBox(height: 24),

                  // Sign up link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${AppStrings.noAccount.tr()} ',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 14)),
                        GestureDetector(
                          onTap: () => AppNavigator.push(const RegisterScreen()),
                          child: Text(
                            AppStrings.signUp.tr(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab Switcher
// ─────────────────────────────────────────────────────────────
class _TabSwitcher extends StatelessWidget {
  final int selected;
  final void Function(int) onTap;
  const _TabSwitcher({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(children: [
        _TabItem(
            label: AppStrings.tabEmail.tr(),
            isSelected: selected == 0,
            onTap: () => onTap(0)),
        _TabItem(
            label: AppStrings.tabMobile.tr(),
            isSelected: selected == 1,
            onTap: () => onTap(1)),
      ]),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabItem(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.accent)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Email Form
// ─────────────────────────────────────────────────────────────
class _EmailForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberMe;
  final VoidCallback onForgotPassword;

  const _EmailForm({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onRememberMe,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.labelEmail.tr(),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: emailController,
          hintText: AppStrings.hintEmail.tr(),
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.mail_outline_rounded,
                  color: AppColors.primary, size: 22)),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return AppStrings.validationEmailRequired.tr();
            }
            if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v)) {
              return AppStrings.validationEmailInvalid.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Text(AppStrings.labelPassword.tr(),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: passwordController,
          hintText: AppStrings.hintPassword.tr(),
          obscureText: obscurePassword,
          prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.lock_outline_rounded,
                  color: AppColors.primary, size: 22)),
          suffixIcon: GestureDetector(
            onTap: onTogglePassword,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                obscurePassword
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
            if (v.length < 8) return AppStrings.validationPasswordMin.tr();
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Remember me & Forgot password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Row(children: [
            //   SizedBox(
            //     width: 20,
            //     height: 20,
            //     child: Checkbox(
            //       value: rememberMe,
            //       onChanged: onRememberMe,
            //       activeColor: AppColors.primary,
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(4)),
            //       side: const BorderSide(color: AppColors.textLight),
            //     ),
            //   ),
            //   const SizedBox(width: 8),
            //   Text(AppStrings.rememberMe.tr(),
            //       style: const TextStyle(
            //           fontSize: 13, color: AppColors.textSecondary)),
            // ]),
            const Spacer(),
            GestureDetector(
              onTap: onForgotPassword,
              child: Text(AppStrings.forgotPassword.tr(),
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Phone Form — single field with tappable country code prefix
// ─────────────────────────────────────────────────────────────
class _PhoneForm extends StatelessWidget {
  final TextEditingController phoneController;
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel?> onCountryChanged;

  const _PhoneForm({
    required this.phoneController,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  Future<void> _openCountryDialog(
      BuildContext context, List<CountryModel> countries) async {
    final picked = await showDialog<CountryModel>(
      context: context,
      builder: (_) =>
          _CountrySearchDialog(countries: countries, selected: selectedCountry),
    );
    if (picked != null) onCountryChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.labelMobilePhone.tr(),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),

        // ── Single combined field ────────────────────────────────
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (_, s) =>
          s is CountriesLoading ||
              s is CountriesLoaded ||
              s is CountriesError,
          builder: (context, state) {
            final countries =
            state is CountriesLoaded ? state.countries : <CountryModel>[];
            final isLoading = state is CountriesLoading;

            return FormField<String>(
              validator: (_) {
                if (phoneController.text.trim().isEmpty) {
                  return AppStrings.validationPhoneRequired.tr();
                }
                if (selectedCountry == null) {
                  return AppStrings.validationCountryRequired.tr();
                }
                return null;
              },
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: field.hasError
                            ? AppColors.error
                            : Colors.grey.shade300,
                        width: field.hasError ? 1.0 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // ── Tappable country code prefix ───────────
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => _openCountryDialog(context, countries),
                          child: Container(
                            height: 54,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    color: Colors.grey.shade200, width: 1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLoading)
                                  const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  )
                                else if (selectedCountry != null) ...[
                                  ClipOval(
                                    child: Image.network(
                                      selectedCountry!.image,
                                      width: 22, height: 22,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.flag_outlined,
                                          size: 18,
                                          color: AppColors.textLight),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    selectedCountry!.phoneCode,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary),
                                  ),
                                ] else ...[
                                  const Icon(Icons.language_outlined,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 4),
                                  Text(AppStrings.hintCountry.tr(),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400)),
                                ],
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textLight, size: 18),
                              ],
                            ),
                          ),
                        ),

                        // ── Phone number input ─────────────────────
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: AppStrings.hintMobilePhone.tr(),
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                            ),
                            onChanged: (_) => field.didChange(null),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 16),
                      child: Text(field.errorText!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 12)),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Country Search Dialog (shared with register screen logic)
// ─────────────────────────────────────────────────────────────
class _CountrySearchDialog extends StatefulWidget {
  final List<CountryModel> countries;
  final CountryModel? selected;

  const _CountrySearchDialog({required this.countries, this.selected});

  @override
  State<_CountrySearchDialog> createState() => _CountrySearchDialogState();
}

class _CountrySearchDialogState extends State<_CountrySearchDialog> {
  final _searchCtrl = TextEditingController();
  List<CountryModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.countries;
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.countries
          : widget.countries
          .where((c) =>
      c.nameEn.toLowerCase().contains(q) ||
          c.nameAr.contains(q) ||
          c.phoneCode.contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final mq     = MediaQuery.of(context);
    final availableHeight = mq.size.height - mq.viewInsets.bottom - 48;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // NOTE: don't add mq.viewInsets.bottom here — Dialog already shifts
      // its content above the keyboard internally. Adding it again here
      // double-counts the keyboard height and crushes the dialog.
      insetPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(children: [
                  Expanded(
                      child: Text(AppStrings.selectCountry.tr(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppColors.textLight, size: 22),
                  ),
                ]),
              ),
            ),
            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchCountry.tr(),
                    hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textLight, size: 20),
                    filled: true,
                    fillColor: AppColors.cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            // List
            _filtered.isEmpty
                ? SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(AppStrings.noResults.tr(),
                      style: const TextStyle(
                          color: AppColors.textLight)),
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final c = _filtered[i];
                  final isSelected = widget.selected?.id == c.id;
                  return ListTile(
                    onTap: () => Navigator.pop(context, c),
                    selected: isSelected,
                    selectedTileColor: AppColors.cardColor,
                    leading: ClipOval(
                      child: Image.network(c.image,
                          width: 32, height: 32, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.flag_outlined,
                              size: 32,
                              color: AppColors.textLight)),
                    ),
                    title: Text(c.displayName(locale),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        )),
                    trailing: Text(c.phoneCode,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  );
                },
                childCount: _filtered.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Or Divider
// ─────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  final String label;
  const _OrDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Social Button
// ─────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  const _SocialButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          icon,
          const SizedBox(width: 5),
          Flexible(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Guest Button
// ─────────────────────────────────────────────────────────────
class _GuestButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GuestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accentLight),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(AppImages.guestIcon,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.person_outline, color: AppColors.primary, size: 22)),
          const SizedBox(width: 8),
          Text(AppStrings.continueAsGuest.tr(),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logo Placeholder
// ─────────────────────────────────────────────────────────────
class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 160,
      alignment: Alignment.center,
      child: const Text('البيان',
          style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontFamily: 'Rubik')),
    );
  }
}