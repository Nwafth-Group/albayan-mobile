// ============================================
// FILE: lib/fatures/settings/screens/about_us_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/link_launcher.dart';
import '../data/datasource/company_remote_data_source.dart';
import '../data/models/company_info_model.dart';
import 'cubit/company_info_cubit.dart';
import 'widgets/company_widgets.dart';
import 'widgets/settings_widgets.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CompanyInfoCubit(CompanyRemoteDataSourceImpl(ApiService()))..load(),
      child: const _AboutUsView(),
    );
  }
}

class _AboutUsView extends StatelessWidget {
  const _AboutUsView();

  /// Keep in sync with `version:` in pubspec.yaml.
  static const _appVersion = '1.0.0';

  void _comingSoon() => Helpers.showError(AppStrings.featureComingSoon.tr());

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    );
    const bodyStyle = TextStyle(
      fontSize: 12,
      color: AppColors.textPrimary,
      height: 1.35,
    );

    final info = context.watch<CompanyInfoCubit>().state.info;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(title: AppStrings.aboutUs.tr()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Logo ──
          Image.asset(AppImages.logo, height: 90),
          const SizedBox(height: 6),
          const Text(
            'مجلــة البيـــان',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: AppColors.primary),
          ),
          const Text(
            'ALBAYAN MAGAZINE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.5,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 22),

          // ── About / mission ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: settingsCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.magazineName.tr(), style: titleStyle),
                const SizedBox(height: 2),
                Text(AppStrings.aboutMagazineDesc.tr(), style: bodyStyle),
                const SizedBox(height: 12),
                Text(AppStrings.ourMission.tr(), style: titleStyle),
                const SizedBox(height: 2),
                Text(AppStrings.ourMissionDesc1.tr(), style: bodyStyle),
                const SizedBox(height: 12),
                Text(AppStrings.ourMissionDesc2.tr(), style: bodyStyle),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Features ──
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FeatureCard(
                  icon: HugeIcons.strokeRoundedBook02,
                  title: AppStrings.featureLibraryTitle.tr(),
                  desc: AppStrings.featureLibraryDesc.tr(),
                ),
                const SizedBox(width: 8),
                _FeatureCard(
                  icon: HugeIcons.strokeRoundedStar,
                  title: AppStrings.featurePersonalTitle.tr(),
                  desc: AppStrings.featurePersonalDesc.tr(),
                ),
                const SizedBox(width: 8),
                _FeatureCard(
                  icon: HugeIcons.strokeRoundedSmartPhone01,
                  title: AppStrings.featureAnywhereTitle.tr(),
                  desc: AppStrings.featureAnywhereDesc.tr(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Company info (from /public/company-info) ──
          if (info != null) ...[
            CompanyDetailsCard(
              info: info,
              title: AppStrings.companyInfoTitle.tr(),
              showCompany: true,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 14),

          // ── Story video ──
          Text(
            AppStrings.watchOurStory.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // TODO: play the real story video once its URL is provided.
          GestureDetector(
            onTap: _comingSoon,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.surfaceVariant, AppColors.accentLight],
                ),
              ),
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ── Social ── (only the networks the company has a link for)
          if (info != null) _SocialRow(info: info),
          const SizedBox(height: 40),
          Text(
            AppStrings.copyrightText.tr(
              namedArgs: {'year': '${DateTime.now().year}'},
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
          Text(
            AppStrings.versionLabel.tr(namedArgs: {'version': _appVersion}),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
        decoration: settingsCard(),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.accentPale,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(icon: icon, color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  final CompanyInfoModel info;
  const _SocialRow({required this.info});

  @override
  Widget build(BuildContext context) {
    final links = [
      (
        HugeIcons.strokeRoundedFacebook01,
        const Color(0xFF1877F2),
        info.facebook,
      ),
      (HugeIcons.strokeRoundedNewTwitter, Colors.black, info.twitter),
      (
        HugeIcons.strokeRoundedInstagram,
        const Color(0xFFE1306C),
        info.instagram,
      ),
      (
        HugeIcons.strokeRoundedLinkedin01,
        const Color(0xFF0A66C2),
        info.linkedin,
      ),
    ].where((l) => l.$3 != null);
    if (links.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (icon, color, url) in links)
          IconButton(
            onPressed: () => LinkLauncher.openUrl(url),
            icon: HugeIcon(icon: icon, color: color, size: 26),
          ),
      ],
    );
  }
}
