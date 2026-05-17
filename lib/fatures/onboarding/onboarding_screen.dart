
// ============================================
// FILE: lib/fatures/onboarding/onboarding_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/app_navigator.dart';
import '../../widgets/custom_button.dart';
import '../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      image: AppImages.onboarding1,
      titleKey: AppStrings.onboarding1Title,
      subtitleKey: AppStrings.onboarding1Subtitle,
    ),
    _OnboardingData(
      image: AppImages.onboarding2,
      titleKey: AppStrings.onboarding2Title,
      subtitleKey: AppStrings.onboarding2Subtitle,
    ),
    _OnboardingData(
      image: AppImages.onboarding3,
      titleKey: AppStrings.onboarding3Title,
      subtitleKey: AppStrings.onboarding3Subtitle,
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _onSkip() => _goToLogin();

  void _onGetStarted() => _goToLogin();

  void _goToLogin() {
    AppNavigator.pushAndRemoveUntil(const LoginScreen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── PageView ──────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (_, index) => _OnboardingPage(data: _pages[index]),
          ),

          // ── Bottom controls ───────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _isLastPage
                ? _LastPageControls(onGetStarted: _onGetStarted)
                : _NormalControls(
              currentPage: _currentPage,
              total: _pages.length,
              onSkip: _onSkip,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Single onboarding page
// ─────────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // ── Image section with gradient fade ─────────────────
        SizedBox(
          height: screenHeight * 0.60,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                data.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                ),
              ),

              // Bottom gradient fade to white
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * 0.22,
                  decoration: const BoxDecoration(
                    // gradient: LinearGradient(
                    //   begin: Alignment.bottomCenter,
                    //   end: Alignment.topCenter,
                    //   colors: [
                    //     Colors.white,
                    //     Colors.transparent,
                    //   ],
                    // ),
                  ),
                ),
              ),

              // Logo circle centered at bottom of image
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      AppImages.onboardingLogo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.article_outlined,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Text section ──────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 28),
                Text(
                  data.titleKey.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.subtitleKey.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Space for bottom controls
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom bar for pages 1 & 2  (Skip + dots)
// ─────────────────────────────────────────────────────────────
class _NormalControls extends StatelessWidget {
  final int currentPage;
  final int total;
  final VoidCallback onSkip;

  const _NormalControls({
    required this.currentPage,
    required this.total,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip
          GestureDetector(
            onTap: onSkip,
            child: Text(
              AppStrings.onboardingSkip.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

          // Page dots
          Row(
            children: List.generate(total, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom bar for last page  (Get Started button)
// ─────────────────────────────────────────────────────────────
class _LastPageControls extends StatelessWidget {
  final VoidCallback onGetStarted;
  const _LastPageControls({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: CustomButton(
          text: AppStrings.onboardingGetStarted.tr(),
          onPressed: onGetStarted,
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Data model for each page
// ─────────────────────────────────────────────────────────────
class _OnboardingData {
  final String image;
  final String titleKey;
  final String subtitleKey;

  const _OnboardingData({
    required this.image,
    required this.titleKey,
    required this.subtitleKey,
  });
}