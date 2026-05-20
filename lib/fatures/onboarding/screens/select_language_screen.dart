
// ============================================
// FILE: lib/fatures/language/screens/select_language_screen.dart
// ============================================

import 'package:albayan/fatures/onboarding/data/language_model.dart';
import 'package:albayan/fatures/onboarding/data/language_remote_datasource.dart';
import 'package:albayan/fatures/onboarding/screens/cubit/language_cubit.dart';
import 'package:albayan/fatures/onboarding/screens/cubit/language_state.dart';
import 'package:albayan/fatures/onboarding/screens/onboarding_screen.dart';
import 'package:albayan/utils/api_client.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/utils/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────
class SelectLanguageScreen extends StatelessWidget {
  const SelectLanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      LanguageCubit(LanguageRemoteDataSource(ApiService()))
        ..fetchLanguages(),
      child: const _SelectLanguageBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────
class _SelectLanguageBody extends StatefulWidget {
  const _SelectLanguageBody();

  @override
  State<_SelectLanguageBody> createState() => _SelectLanguageBodyState();
}

class _SelectLanguageBodyState extends State<_SelectLanguageBody> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue(LanguageModel selected) async {
    // 1. Persist language code
    await SharedPrefHelper.saveLng(selected.code);

    // 2. Change app locale via easy_localization
    if (mounted) {
      await context.setLocale(Locale(selected.code));
      // 3. Navigate to login
      AppNavigator.pushAndRemoveUntil(const OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.selectLanguageTitle.tr(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.selectLanguageSubtitle.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Search ─────────────────────────────────
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: AppStrings.searchLanguage.tr(),
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 15),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: AppColors.primary, size: 22),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // ── List ────────────────────────────────────────
                Expanded(
                  child: _buildList(context, state),
                ),

                // ── Continue Button ──────────────────────────────
                _buildContinueButton(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, LanguageState state) {
    if (state is LanguageLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is LanguageError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(state.message,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  context.read<LanguageCubit>().fetchLanguages(),
              child: Text(AppStrings.retry.tr(),
                  style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }

    if (state is LanguageLoaded) {
      final query    = _searchCtrl.text.toLowerCase();
      final filtered = query.isEmpty
          ? state.languages
          : state.languages
          .where((l) =>
      l.nameEn.toLowerCase().contains(query) ||
          l.nameAr.contains(query) ||
          l.code.contains(query))
          .toList();

      if (filtered.isEmpty) {
        return Center(
          child: Text(AppStrings.noResults.tr(),
              style: const TextStyle(color: AppColors.textLight)),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final lang       = filtered[i];
          final isSelected = state.selected?.id == lang.id;
          final locale     = context.locale.languageCode;

          return _LanguageTile(
            language:   lang,
            isSelected: isSelected,
            locale:     locale,
            onTap: () =>
                context.read<LanguageCubit>().selectLanguage(lang),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildContinueButton(BuildContext context, LanguageState state) {
    final selected =
    state is LanguageLoaded ? state.selected : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed:
          selected == null ? null : () => _onContinue(selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.surfaceVariant,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            AppStrings.btnContinue.tr(),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Language Tile
// ─────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final String locale;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPale : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Flag
            ClipOval(
              child: language.imageUrl != null
                  ? Image.network(
                language.imageUrl!,
                width: 32, height: 32, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _FlagFallback(code: language.code),
              )
                  : _FlagFallback(code: language.code),
            ),
            const SizedBox(width: 14),

            // Name
            Expanded(
              child: Text(
                language.displayName(locale),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Flag fallback (letter avatar)
// ─────────────────────────────────────────────────────────────
class _FlagFallback extends StatelessWidget {
  final String code;
  const _FlagFallback({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        code.toUpperCase(),
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary),
      ),
    );
  }
}