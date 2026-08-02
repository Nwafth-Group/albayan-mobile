// ============================================
// FILE: lib/fatures/auth/screens/register_screen.dart
// ============================================

import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/constants.dart';
import '../../../utils/api_client.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../data/models/country_model.dart';
import 'otp_screen.dart';
import 'terms_screen.dart';

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(
        AuthRemoteDataSource(ApiService()),
      )..fetchCountries(),
      child: const _RegisterBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main body
// ─────────────────────────────────────────────────────────────
class _RegisterBody extends StatefulWidget {
  const _RegisterBody();

  @override
  State<_RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<_RegisterBody>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  final _firstNameMobCtrl = TextEditingController();
  final _lastNameMobCtrl  = TextEditingController();
  final _phoneCtrl        = TextEditingController();

  CountryModel? _selectedCountry;
  bool _agreeTerms      = false;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _firstNameMobCtrl.dispose();
    _lastNameMobCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _animCtrl.forward(from: 0);
  }

  void _onSignUp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.validationAgreeTerms.tr()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.validationCountryRequired.tr()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final cubit  = context.read<AuthCubit>();
    final locale = context.locale.languageCode;

    if (_selectedTab == 0) {
      cubit.registerWithEmail(
        firstName:            _firstNameCtrl.text.trim(),
        lastName:             _lastNameCtrl.text.trim(),
        email:                _emailCtrl.text.trim(),
        countryId:            _selectedCountry!.id,
        password:             _passwordCtrl.text,
        passwordConfirmation: _confirmPassCtrl.text,
        termsAccepted:        _agreeTerms,
        defaultLanguage:      locale,
      );
    } else {
      // Combine country code + number, e.g. "+962" + "790404479" = "+962790404479"
      final code   = _selectedCountry!.phoneCode;
      final number = _phoneCtrl.text.trim();
      cubit.registerWithMobile(
        firstName:       _firstNameMobCtrl.text.trim(),
        lastName:        _lastNameMobCtrl.text.trim(),
        mobileNumber:    '$code$number',
        countryId:       _selectedCountry!.id,
        termsAccepted:   _agreeTerms,
        defaultLanguage: locale,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // ── Auto-select Saudi Arabia once countries load ───────
        if (state is CountriesLoaded && _selectedCountry == null) {
          final saudi = state.countries.firstWhere(
                (c) => c.nameEn.toLowerCase().contains('saudi'),
            orElse: () => state.countries.first,
          );
          setState(() => _selectedCountry = saudi);
        }

        if (state is RegisterSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthCubit>(),
                child: OtpScreen(
                  recipient: state.recipient,
                  isEmail:   state.isEmail,
                ),
              ),
            ),
          );
        } else if (state is RegisterError) {
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
                  Center(
                    child: Image.asset(
                      AppImages.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const _LogoPlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _TabSwitcher(selected: _selectedTab, onTap: _switchTab),
                  const SizedBox(height: 24),
                  Text(AppStrings.registerTitle.tr(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(AppStrings.registerSubtitle.tr(),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: _selectedTab == 0
                        ? _EmailForm(
                      firstNameController:   _firstNameCtrl,
                      lastNameController:    _lastNameCtrl,
                      emailController:       _emailCtrl,
                      passwordController:    _passwordCtrl,
                      confirmPassController: _confirmPassCtrl,
                      selectedCountry:       _selectedCountry,
                      obscurePassword:       _obscurePassword,
                      obscureConfirm:        _obscureConfirm,
                      onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                      onToggleConfirm:  () => setState(() => _obscureConfirm  = !_obscureConfirm),
                      onCountryChanged: (c) => setState(() => _selectedCountry = c),
                    )
                        : _MobileForm(
                      firstNameController: _firstNameMobCtrl,
                      lastNameController:  _lastNameMobCtrl,
                      phoneController:     _phoneCtrl,
                      selectedCountry:     _selectedCountry,
                      onCountryChanged: (c) => setState(() => _selectedCountry = c),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TermsCheckbox(
                    value: _agreeTerms,
                    onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                    onTermsTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TermsScreen())),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (_, s) =>
                    s is RegisterLoading || s is RegisterSuccess || s is RegisterError,
                    builder: (context, state) => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: CustomButton(
                        text: AppStrings.btnSignUp.tr(),
                        isLoading: state is RegisterLoading,
                        onPressed: _onSignUp,
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _OrDivider(label: AppStrings.orSignUpWith.tr()),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: Image.asset(AppImages.appleIcon, height: 22, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.apple, size: 22)),
                          label: AppStrings.continueWithApple.tr(),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SocialButton(
                          icon: Image.asset(AppImages.googleIcon, height: 22, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22)),
                          label: AppStrings.continueWithGoogle.tr(),
                          onTap: () {},
                        ),
                      ),
                    ],
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
// Country Picker — tappable field that opens a search dialog
// ─────────────────────────────────────────────────────────────
class _CountryDropdown extends StatelessWidget {
  final CountryModel? value;
  final ValueChanged<CountryModel?> onChanged;

  const _CountryDropdown({required this.value, required this.onChanged});

  Future<void> _openDialog(BuildContext context, List<CountryModel> countries) async {
    final picked = await showDialog<CountryModel>(
      context: context,
      builder: (_) => _CountrySearchDialog(countries: countries, selected: value),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (_, s) =>
      s is CountriesLoading || s is CountriesLoaded || s is CountriesError,
      builder: (context, state) {
        // ── Loading ────────────────────────────────────────────
        if (state is CountriesLoading) {
          return _shell(child: const Center(
            child: SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ));
        }

        // ── Error ──────────────────────────────────────────────
        if (state is CountriesError) {
          return _shell(child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(state.message,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  overflow: TextOverflow.ellipsis)),
              TextButton(
                onPressed: () => context.read<AuthCubit>().fetchCountries(),
                child: Text(AppStrings.retry.tr(),
                    style: const TextStyle(color: AppColors.primary, fontSize: 12)),
              ),
            ],
          ));
        }

        // ── Loaded ─────────────────────────────────────────────
        final countries = state is CountriesLoaded ? state.countries : <CountryModel>[];

        return FormField<CountryModel>(
          initialValue: value,
          validator: (_) => value == null ? AppStrings.validationCountryRequired.tr() : null,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openDialog(context, countries),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: field.hasError ? AppColors.error : AppColors.accentLight,
                        width: field.hasError ? 1.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Flag
                        if (value != null) ...[
                          ClipOval(
                            child: Image.network(
                              value!.image,
                              width: 26, height: 26, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.flag_outlined, size: 22, color: AppColors.textLight),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ] else ...[
                          const Icon(Icons.language_outlined, color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                        ],
                        // Name
                        Expanded(
                          child: Text(
                            value != null
                                ? value!.displayName(locale)
                                : AppStrings.hintCountry.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: value != null ? AppColors.textPrimary : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        // Phone code
                        if (value != null) ...[
                          Text(value!.phoneCode,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                        ],
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 16),
                    child: Text(field.errorText!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _shell({required Widget child}) => Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade300, width: 0.5),
    ),
    child: child,
  );
}

// ─────────────────────────────────────────────────────────────
// Country Search Dialog
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

    // Total usable height = screen − keyboard − top/bottom dialog margins
    final availableHeight = mq.size.height - mq.viewInsets.bottom - 48;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // NOTE: don't add mq.viewInsets.bottom here — Dialog already shifts
      // its content above the keyboard internally. Adding it again here
      // double-counts the keyboard height and crushes the dialog.
      insetPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      // ── Hard cap the whole dialog to available height ─────────
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            // ── Header ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.selectCountry.tr(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close,
                          color: AppColors.textLight, size: 22),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search field ──────────────────────────────────
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

            // ── List (scrolls together with header/search) ────
            _filtered.isEmpty
                ? SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(AppStrings.noResults.tr(),
                      style: const TextStyle(color: AppColors.textLight)),
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final c          = _filtered[i];
                  final isSelected = widget.selected?.id == c.id;
                  return ListTile(
                    onTap: () => Navigator.pop(context, c),
                    selected: isSelected,
                    selectedTileColor: AppColors.cardColor,
                    leading: ClipOval(
                      child: Image.network(
                        c.image,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.flag_outlined,
                            size: 32,
                            color: AppColors.textLight),
                      ),
                    ),
                    title: Text(
                      c.displayName(locale),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
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
// Email Form
// ─────────────────────────────────────────────────────────────
class _EmailForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPassController;
  final CountryModel? selectedCountry;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final ValueChanged<CountryModel?> onCountryChanged;

  const _EmailForm({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPassController,
    required this.selectedCountry,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(AppStrings.labelFirstName.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: firstNameController,
          hintText: AppStrings.hintFirstName.tr(),
          prefixIcon: const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22)),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationFirstNameRequired.tr() : null,
        ),
        const SizedBox(height: 16),

        _FieldLabel(AppStrings.labelLastName.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: lastNameController,
          hintText: AppStrings.hintLastName.tr(),
          prefixIcon: const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22)),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationLastNameRequired.tr() : null,
        ),
        const SizedBox(height: 16),

        _FieldLabel(AppStrings.labelEmail.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: emailController,
          hintText: AppStrings.hintEmail.tr(),
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 22)),
          validator: (v) {
            if (v == null || v.isEmpty) return AppStrings.validationEmailRequired.tr();
            if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v))
              return AppStrings.validationEmailInvalid.tr();
            return null;
          },
        ),
        const SizedBox(height: 16),

        _FieldLabel(AppStrings.labelCountry.tr()),
        const SizedBox(height: 8),
        _CountryDropdown(value: selectedCountry, onChanged: onCountryChanged),
        const SizedBox(height: 16),

        _FieldLabel(AppStrings.labelPassword.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: passwordController,
          hintText: AppStrings.hintPassword.tr(),
          obscureText: obscurePassword,
          prefixIcon: const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22)),
          suffixIcon: GestureDetector(onTap: onTogglePassword,
              child: Padding(padding: const EdgeInsets.all(12),
                  child: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textLight, size: 22))),
          validator: (v) {
            if (v == null || v.isEmpty) return AppStrings.validationPasswordRequired.tr();
            if (v.length < 8) return AppStrings.validationPasswordMin.tr();
            return null;
          },
        ),
        const SizedBox(height: 16),

        _FieldLabel(AppStrings.labelConfirmPassword.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: confirmPassController,
          hintText: AppStrings.hintConfirmPassword.tr(),
          obscureText: obscureConfirm,
          prefixIcon: const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22)),
          suffixIcon: GestureDetector(onTap: onToggleConfirm,
              child: Padding(padding: const EdgeInsets.all(12),
                  child: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textLight, size: 22))),
          validator: (v) {
            if (v == null || v.isEmpty) return AppStrings.validationConfirmPasswordRequired.tr();
            if (v != passwordController.text) return AppStrings.validationPasswordMismatch.tr();
            return null;
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Mobile Form
// ─────────────────────────────────────────────────────────────
class _MobileForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel?> onCountryChanged;

  const _MobileForm({
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(AppStrings.labelFirstName.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: firstNameController,
          hintText: AppStrings.hintFirstName.tr(),
          prefixIcon: const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22)),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationFirstNameRequired.tr() : null,
        ),
        const SizedBox(height: 16),

        _FieldLabel(AppStrings.labelLastName.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: lastNameController,
          hintText: AppStrings.hintLastName.tr(),
          prefixIcon: const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22)),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationLastNameRequired.tr() : null,
        ),
        const SizedBox(height: 16),

        _FieldLabel(AppStrings.labelCountry.tr()),
        const SizedBox(height: 8),
        _CountryDropdown(value: selectedCountry, onChanged: onCountryChanged),
        const SizedBox(height: 16),

        _FieldLabel(AppStrings.labelMobilePhone.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: phoneController,
          hintText: AppStrings.hintMobilePhone.tr(),
          keyboardType: TextInputType.phone,
          prefixIcon: selectedCountry != null
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ClipOval(
                child: Image.network(selectedCountry!.image,
                    width: 20, height: 20, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20)),
              ),
              const SizedBox(width: 4),
              Text(selectedCountry!.phoneCode,
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            ]),
          )
              : const Padding(padding: EdgeInsets.all(12),
              child: Icon(Icons.phone_outlined, color: AppColors.primary, size: 22)),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationPhoneRequired.tr() : null,
        ),
      ],
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
        _TabItem(label: AppStrings.tabEmail.tr(),  isSelected: selected == 0, onTap: () => onTap(0)),
        _TabItem(label: AppStrings.tabMobile.tr(), isSelected: selected == 1, onTap: () => onTap(1)),
      ]),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabItem({required this.label, required this.isSelected, required this.onTap});

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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.accent)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Terms Checkbox
// ─────────────────────────────────────────────────────────────
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;
  const _TermsCheckbox({required this.value, required this.onChanged, required this.onTermsTap});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(width: 20, height: 20,
          child: Checkbox(
            value: value, onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: AppColors.textLight),
          )),
      const SizedBox(width: 8),
      Expanded(
        child: GestureDetector(
          onTap: onTermsTap,
          child: Text(AppStrings.agreeToTerms.tr(),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textSecondary)),
        ),
      ),
    ]);
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
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
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
  const _SocialButton({required this.icon, required this.label, required this.onTap});

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
          Flexible(child: Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Field Label
// ─────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
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
      height: 90, width: 160, alignment: Alignment.center,
      child: const Text('البيان',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
              color: AppColors.primary, fontFamily: 'Rubik')),
    );
  }
}