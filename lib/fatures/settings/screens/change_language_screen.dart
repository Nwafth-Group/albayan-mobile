// ============================================
// FILE: lib/fatures/settings/screens/change_language_screen.dart
// ============================================

import 'package:albayan/fatures/onboarding/data/language_model.dart';
import 'package:albayan/fatures/onboarding/data/language_remote_datasource.dart';
import 'package:albayan/fatures/onboarding/screens/cubit/language_cubit.dart';
import 'package:albayan/fatures/onboarding/screens/cubit/language_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import 'widgets/settings_widgets.dart';

class ChangeLanguageScreen extends StatelessWidget {
  const ChangeLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LanguageCubit(LanguageRemoteDataSource(ApiService()))
            ..fetchLanguages(),
      child: const _ChangeLanguageBody(),
    );
  }
}

class _ChangeLanguageBody extends StatefulWidget {
  const _ChangeLanguageBody();

  @override
  State<_ChangeLanguageBody> createState() => _ChangeLanguageBodyState();
}

class _ChangeLanguageBodyState extends State<_ChangeLanguageBody> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _select(LanguageModel language) async {
    if (language.code == context.locale.languageCode) return;

    // The app only ships translations for its supported locales; other
    // languages returned by the API can't be applied yet.
    final supported = context.supportedLocales.any(
      (l) => l.languageCode == language.code,
    );
    if (!supported) {
      Helpers.showError(AppStrings.featureComingSoon.tr());
      return;
    }

    await SharedPrefHelper.saveLng(language.code);
    if (!mounted) return;
    await context.setLocale(Locale(language.code));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final code = context.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(title: AppStrings.changeLanguage.tr()),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SettingsField(
              hint: AppStrings.searchHint.tr(),
              controller: _search,
              borderColor: AppColors.primary,
              suffix: const Padding(
                padding: EdgeInsets.all(12),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, state) {
                if (state is LanguageError) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: AppStrings.somethingWentWrong.tr(),
                    subtitle: state.message,
                    action: CustomButton(
                      text: AppStrings.retry.tr(),
                      onPressed: () =>
                          context.read<LanguageCubit>().fetchLanguages(),
                    ),
                  );
                }
                if (state is! LanguageLoaded) return const LoadingIndicator();

                return ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _search,
                  builder: (context, value, _) {
                    final query = value.text.trim().toLowerCase();
                    final languages = state.languages.where((l) {
                      if (query.isEmpty) return true;
                      return l.nameEn.toLowerCase().contains(query) ||
                          l.nameAr.contains(query) ||
                          l.code.toLowerCase().contains(query);
                    }).toList();

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: languages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _LanguageTile(
                        language: languages[i],
                        selected: languages[i].code == code,
                        onTap: () => _select(languages[i]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageModel language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // As in the design, each language shows in its own script: RTL
    // languages (العربية, فارسي, اردو) by their Arabic-script name.
    final name = language.isRtl ? language.nameAr : language.nameEn;
    final flag = language.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.cardColor : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accentLight : settingsBorder,
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 30,
                height: 30,
                child: (flag == null || flag.isEmpty)
                    ? Container(
                        color: AppColors.surfaceVariant,
                        alignment: Alignment.center,
                        child: Text(
                          language.code.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Image.network(
                        flag,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.surfaceVariant),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : settingsBorder,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
