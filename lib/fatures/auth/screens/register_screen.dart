
// ============================================
// FILE: lib/fatures/auth/screens/register_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'otp_screen.dart';
import 'terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Tab: 0 = Email, 1 = Mobile
  int _selectedTab = 0;

  final _formKey = GlobalKey<FormState>();

  // Email tab controllers
  final _firstNameController   = TextEditingController();
  final _lastNameController    = TextEditingController();
  final _emailController       = TextEditingController();
  final _passwordController    = TextEditingController();
  final _confirmPassController = TextEditingController();

  // Mobile tab controllers
  final _firstNameMobController = TextEditingController();
  final _lastNameMobController  = TextEditingController();
  final _phoneController        = TextEditingController();

  // Shared
  String? _selectedCountry;
  bool _agreeTerms      = false;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  late AnimationController _animationController;
  late Animation<double>   _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    _firstNameMobController.dispose();
    _lastNameMobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _animationController.forward(from: 0);
  }

  void _onSignUp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.validationAgreeTerms.tr()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Dispatch register cubit event
    // On success navigate to OTP screen
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final isEmail   = _selectedTab == 0;
      final recipient = isEmail
          ? _emailController.text.trim()
          : _phoneController.text.trim();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            recipient: recipient,
            isEmail: isEmail,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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

                // ── Tab Switcher ──────────────────────────────────
                _TabSwitcher(
                  selected: _selectedTab,
                  onTap: _switchTab,
                ),
                const SizedBox(height: 24),

                // ── Heading ───────────────────────────────────────
                Text(
                  AppStrings.registerTitle.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.registerSubtitle.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Animated Form ─────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _selectedTab == 0
                      ? _EmailForm(
                    firstNameController:   _firstNameController,
                    lastNameController:    _lastNameController,
                    emailController:       _emailController,
                    passwordController:    _passwordController,
                    confirmPassController: _confirmPassController,
                    selectedCountry:       _selectedCountry,
                    obscurePassword:       _obscurePassword,
                    obscureConfirm:        _obscureConfirm,
                    onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                    onToggleConfirm: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                    onCountryChanged: (v) =>
                        setState(() => _selectedCountry = v),
                  )
                      : _MobileForm(
                    firstNameController: _firstNameMobController,
                    lastNameController:  _lastNameMobController,
                    phoneController:     _phoneController,
                    selectedCountry:     _selectedCountry,
                    onCountryChanged: (v) =>
                        setState(() => _selectedCountry = v),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Terms checkbox ────────────────────────────────
                _TermsCheckbox(
                  value: _agreeTerms,
                  onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                  onTermsTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TermsScreen()),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign Up Button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CustomButton(
                    text: AppStrings.btnSignUp.tr(),
                    isLoading: _isLoading,
                    onPressed: _onSignUp,
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Or sign up with ───────────────────────────────
                _OrDivider(label: AppStrings.orSignUpWith.tr()),
                const SizedBox(height: 20),

                // ── Social Buttons ────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        icon: Image.asset(AppImages.appleIcon,
                            height: 22, fit: BoxFit.contain),
                        label: AppStrings.continueWithApple.tr(),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SocialButton(
                        icon: Image.asset(AppImages.googleIcon,
                            height: 22, fit: BoxFit.contain),
                        label: AppStrings.continueWithGoogle.tr(),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
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
      child: Row(
        children: [
          _TabItem(
            label: AppStrings.tabEmail.tr(),
            isSelected: selected == 0,
            onTap: () => onTap(0),
          ),
          _TabItem(
            label: AppStrings.tabMobile.tr(),
            isSelected: selected == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Email Registration Form
// ─────────────────────────────────────────────────────────────
class _EmailForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPassController;
  final String? selectedCountry;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final ValueChanged<String?> onCountryChanged;

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
        // First Name
        _FieldLabel(AppStrings.labelFirstName.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: firstNameController,
          hintText: AppStrings.hintFirstName.tr(),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.person_outline_rounded,
                color: AppColors.primary, size: 22),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationFirstNameRequired.tr()
              : null,
        ),
        const SizedBox(height: 16),

        // Last Name
        _FieldLabel(AppStrings.labelLastName.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: lastNameController,
          hintText: AppStrings.hintLastName.tr(),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.person_outline_rounded,
                color: AppColors.primary, size: 22),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationLastNameRequired.tr()
              : null,
        ),
        const SizedBox(height: 16),

        // Email
        _FieldLabel(AppStrings.labelEmail.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: emailController,
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
            if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v)) {
              return AppStrings.validationEmailInvalid.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Country
        _FieldLabel(AppStrings.labelCountry.tr()),
        const SizedBox(height: 8),
        _CountryDropdown(
          value: selectedCountry,
          onChanged: onCountryChanged,
        ),
        const SizedBox(height: 16),

        // Password
        _FieldLabel(AppStrings.labelPassword.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: passwordController,
          hintText: AppStrings.hintPassword.tr(),
          obscureText: obscurePassword,
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.lock_outline_rounded,
                color: AppColors.primary, size: 22),
          ),
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
        const SizedBox(height: 16),

        // Confirm Password
        _FieldLabel(AppStrings.labelConfirmPassword.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: confirmPassController,
          hintText: AppStrings.hintConfirmPassword.tr(),
          obscureText: obscureConfirm,
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.lock_outline_rounded,
                color: AppColors.primary, size: 22),
          ),
          suffixIcon: GestureDetector(
            onTap: onToggleConfirm,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textLight,
                size: 22,
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return AppStrings.validationConfirmPasswordRequired.tr();
            }
            if (v != passwordController.text) {
              return AppStrings.validationPasswordMismatch.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Mobile Registration Form
// ─────────────────────────────────────────────────────────────
class _MobileForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;

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
        // First Name
        _FieldLabel(AppStrings.labelFirstName.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: firstNameController,
          hintText: AppStrings.hintFirstName.tr(),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.person_outline_rounded,
                color: AppColors.primary, size: 22),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationFirstNameRequired.tr()
              : null,
        ),
        const SizedBox(height: 16),

        // Last Name
        _FieldLabel(AppStrings.labelLastName.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: lastNameController,
          hintText: AppStrings.hintLastName.tr(),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.person_outline_rounded,
                color: AppColors.primary, size: 22),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? AppStrings.validationLastNameRequired.tr()
              : null,
        ),
        const SizedBox(height: 16),

        // Country
        _FieldLabel(AppStrings.labelCountry.tr()),
        const SizedBox(height: 8),
        _CountryDropdown(
          value: selectedCountry,
          onChanged: onCountryChanged,
        ),
        const SizedBox(height: 16),

        // Mobile Phone
        _FieldLabel(AppStrings.labelMobilePhone.tr()),
        const SizedBox(height: 8),
        CustomTextField(
          controller: phoneController,
          hintText: AppStrings.hintMobilePhone.tr(),
          keyboardType: TextInputType.phone,
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.phone_outlined,
                color: AppColors.primary, size: 22),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return AppStrings.validationPhoneRequired.tr();
            }
            final cleaned = v.replaceAll(RegExp(r'[\s\-\(\)]'), '');
            if (!RegExp(r'^(07[0-9]{8}|(7[0-9]{8}))$').hasMatch(cleaned)) {
              return AppStrings.validationPhoneInvalid.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Country Dropdown
// ─────────────────────────────────────────────────────────────
class _CountryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  static const List<String> _countries = [
    'Jordan',
    'Saudi Arabia',
    'United Arab Emirates',
    'Kuwait',
    'Qatar',
    'Bahrain',
    'Oman',
    'Egypt',
    'Lebanon',
    'Iraq',
  ];

  const _CountryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: AppStrings.hintCountry.tr(),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.language_outlined,
              color: AppColors.primary, size: 22),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary),
      validator: (v) =>
      v == null ? AppStrings.validationCountryRequired.tr() : null,
      items: _countries
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
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

  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.textLight),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onTermsTap,
            child: Text(
              AppStrings.agreeToTerms.tr(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
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
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Social Button
// ─────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
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
      child: const Text(
        'البيان',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          fontFamily: 'Rubik',
        ),
      ),
    );
  }
}