
// ============================================
// FILE: lib/fatures/auth/screens/login_screen.dart
// ============================================

import 'package:albayan/fatures/auth/screens/forgot_password_screen.dart';
import 'package:albayan/fatures/auth/screens/register_screen.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Tab: 0 = Email, 1 = Mobile
  int _selectedTab = 0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _animationController.forward(from: 0);
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      // TODO: Dispatch login cubit event
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
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
                // ── Logo ──────────────────────────────────────────
                Center(
                  child: Image.asset(
                    AppImages.logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _LogoPlaceholder(),
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
                  AppStrings.loginTitle.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.loginSubtitle.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Animated Form Fields ──────────────────────────
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _selectedTab == 0
                      ? _EmailForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    rememberMe: _rememberMe,
                    onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                    onRememberMe: (v) =>
                        setState(() => _rememberMe = v ?? false),
                    onForgotPassword: () => AppNavigator.push(const ForgotPasswordScreen()),
                  )
                      : _PhoneForm(
                    phoneController: _phoneController,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Login Button ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CustomButton(
                    text: AppStrings.btnLogin.tr(),
                    isLoading: _isLoading,
                    onPressed: _onLogin,
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Or continue with ─────────────────────────────
                const _OrDivider(),
                const SizedBox(height: 20),

                // ── Social Buttons ────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        icon: Image.asset(
                          AppImages.appleIcon,
                          fit: BoxFit.contain,
                        ),
                        label: AppStrings.continueWithApple.tr(),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SocialButton(
                        icon: Image.asset(
                          AppImages.googleIcon,
                          fit: BoxFit.contain,
                        ),
                        label: AppStrings.continueWithGoogle.tr(),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Guest Button ──────────────────────────────────
                _GuestButton(onTap: () {}),
                const SizedBox(height: 24),

                // ── Sign Up ───────────────────────────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${AppStrings.noAccount.tr()} ',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab Switcher Widget
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
        border: Border.all(color: AppColors.primaryLight)
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
        Text(
          AppStrings.labelEmail.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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
            final reg = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
            if (!reg.hasMatch(v)) {
              return AppStrings.validationEmailInvalid.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Text(
          AppStrings.labelPassword.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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
            if (v.length < 8) {
              return AppStrings.validationPasswordMin.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Remember me & Forgot password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: onRememberMe,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: AppColors.textLight),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.rememberMe.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onForgotPassword,
              child: Text(
                AppStrings.forgotPassword.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Phone Form
// ─────────────────────────────────────────────────────────────
class _PhoneForm extends StatelessWidget {
  final TextEditingController phoneController;

  const _PhoneForm({required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.labelMobilePhone.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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
// Or Divider
// ─────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.grey.shade300, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppStrings.orContinueWith.tr(),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.grey.shade300, thickness: 1),
        ),
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
          border: Border.all(color: AppColors.accentLight)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.guestIcon,fit: BoxFit.contain,),
            const SizedBox(width: 8),
            Text(
              AppStrings.continueAsGuest.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logo Placeholder (fallback if image not found)
// ─────────────────────────────────────────────────────────────
class _LogoPlaceholder extends StatelessWidget {
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

// ─────────────────────────────────────────────────────────────
// Apple & Google Icon Widgets
// ─────────────────────────────────────────────────────────────
class _AppleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, size: 22, color: Colors.black);
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -1.9, 1.6, false, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -0.3, 1.6, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        1.3, 1.6, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        2.9, 1.2, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + radius, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}