// ============================================
// FILE: lib/fatures/settings/screens/settings_screen.dart
// ============================================

import 'package:albayan/fatures/articles/screens/widgets/rate_experience_sheet.dart';
import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_cubit.dart';
import 'package:albayan/fatures/auth/screens/cubit/auth_state.dart';
import 'package:albayan/fatures/auth/screens/login_screen.dart';
import 'package:albayan/fatures/issues/screens/archive_years_screen.dart';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/shared_pref_helper.dart';
import 'about_us_screen.dart';
import 'change_language_screen.dart';
import 'change_password_screen.dart';
import 'contact_us_screen.dart';
import 'orders_screen.dart';
import 'privacy_policy_screen.dart';
import 'profile_screen.dart';
import 'redeem_gift_screen.dart';
import 'subscriptions_screen.dart';
import 'terms_conditions_screen.dart';
import 'widgets/settings_widgets.dart';

class SettingsScreen extends StatelessWidget {
  /// Back arrow action — the Settings tab uses it to return to Home.
  final VoidCallback? onBack;

  const SettingsScreen({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRemoteDataSource(ApiService())),
      child: _SettingsBody(onBack: onBack),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final VoidCallback? onBack;
  const _SettingsBody({this.onBack});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showSettingsSheet(
      context,
      title: AppStrings.logoutTitle.tr(),
      titleColor: AppColors.primary,
      message: AppStrings.logoutQuestion.tr(),
      secondaryText: AppStrings.cancel.tr(),
      primaryText: AppStrings.yesLogout.tr(),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    // TODO(api): call the restore-purchases endpoint (store receipts) once
    // it exists; until then there is never anything to restore.
    final backHome = await showSettingsSheet(
      context,
      title: AppStrings.restorePurchases.tr(),
      message: AppStrings.noPurchasesRestored.tr(),
      primaryText: AppStrings.backToHome.tr(),
    );
    if (backHome == true) onBack?.call();
  }

  Future<void> _rateApplication(BuildContext context) async {
    final result = await showRateExperienceSheet(context);
    if (result == null || !context.mounted) return;
    // TODO(api): submit `result.rating` / `result.comment` to the app
    // review endpoint once it exists.
    final backHome = await showSettingsSheet(
      context,
      title: AppStrings.thanksFeedback.tr(),
      message: AppStrings.thanksFeedbackDesc.tr(),
      primaryText: AppStrings.backToHome.tr(),
    );
    if (backHome == true) onBack?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = SharedPrefHelper.isLoggedIn();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          AppNavigator.pushAndRemoveUntil(const LoginScreen());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: SettingsAppBar(
          title: AppStrings.settingsTitle.tr(),
          showBack: onBack != null,
          onBack: onBack,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _SectionLabel(AppStrings.settingsGeneral.tr()),
            if (isLoggedIn) ...[
              _SettingsTile(
                icon: HugeIcons.strokeRoundedUserCircle,
                title: AppStrings.myProfile.tr(),
                onTap: () => AppNavigator.push(const ProfileScreen()),
              ),
              _SettingsTile(
                icon: HugeIcons.strokeRoundedCrown,
                title: AppStrings.mySubscriptions.tr(),
                onTap: () => AppNavigator.push(const SubscriptionsScreen()),
              ),
              _SettingsTile(
                icon: HugeIcons.strokeRoundedShoppingBag01,
                title: AppStrings.myOrder.tr(),
                onTap: () => AppNavigator.push(const OrdersScreen()),
              ),
            ],
            _SettingsTile(
              icon: HugeIcons.strokeRoundedArchive,
              title: AppStrings.settingsArchive.tr(),
              onTap: () => AppNavigator.push(const ArchiveYearsScreen()),
            ),
            if (isLoggedIn) ...[
              _SettingsTile(
                icon: HugeIcons.strokeRoundedRefresh,
                title: AppStrings.restorePurchases.tr(),
                onTap: () => _restorePurchases(context),
              ),
              _SettingsTile(
                icon: HugeIcons.strokeRoundedGift,
                title: AppStrings.redeemGift.tr(),
                onTap: () => AppNavigator.push(const RedeemGiftScreen()),
              ),
              _SettingsTile(
                icon: HugeIcons.strokeRoundedKey01,
                title: AppStrings.changePassword.tr(),
                onTap: () => AppNavigator.push(const ChangePasswordScreen()),
              ),
            ],
            _SettingsTile(
              icon: HugeIcons.strokeRoundedGlobe02,
              title: AppStrings.language.tr(),
              onTap: () => AppNavigator.push(const ChangeLanguageScreen()),
            ),
            const SizedBox(height: 8),
            _SectionLabel(AppStrings.settingsAbout.tr()),
            _SettingsTile(
              icon: HugeIcons.strokeRoundedHeadset,
              title: AppStrings.contactUs.tr(),
              onTap: () => AppNavigator.push(const ContactUsScreen()),
            ),
            _SettingsTile(
              icon: HugeIcons.strokeRoundedInformationCircle,
              title: AppStrings.aboutUs.tr(),
              onTap: () => AppNavigator.push(const AboutUsScreen()),
            ),
            _SettingsTile(
              icon: HugeIcons.strokeRoundedStar,
              title: AppStrings.rateApplication.tr(),
              onTap: () => _rateApplication(context),
            ),
            _SettingsTile(
              icon: HugeIcons.strokeRoundedSecurityCheck,
              title: AppStrings.privacyPolicy.tr(),
              onTap: () => AppNavigator.push(const PrivacyPolicyScreen()),
            ),
            _SettingsTile(
              icon: HugeIcons.strokeRoundedFile01,
              title: AppStrings.termsConditions.tr(),
              onTap: () => AppNavigator.push(const TermsConditionsScreen()),
            ),
            if (isLoggedIn)
              _SettingsTile(
                icon: HugeIcons.strokeRoundedLogout03,
                title: AppStrings.logout.tr(),
                showArrow: false,
                onTap: () => _confirmLogout(context),
              )
            else
              _SettingsTile(
                icon: HugeIcons.strokeRoundedLogout03,
                title: AppStrings.login.tr(),
                showArrow: false,
                onTap: () =>
                    AppNavigator.pushAndRemoveUntil(const LoginScreen()),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: showArrow ? AppColors.textPrimary : AppColors.primary,
                ),
              ),
            ),
            if (showArrow)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.accentPale,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRtl ? Icons.arrow_back : Icons.arrow_forward,
                  size: 12,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
