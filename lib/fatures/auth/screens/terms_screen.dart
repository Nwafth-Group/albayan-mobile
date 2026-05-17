
// ============================================
// FILE: lib/fatures/auth/screens/terms_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepted = false;

  void _onDone() {
    Navigator.pop(context, _accepted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Text(
                  AppStrings.termsTitle.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Scrollable Content ────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TermsClause(
                        title: AppStrings.termsClause1Title.tr(),
                        body: AppStrings.termsClause1Body.tr(),
                      ),
                      const SizedBox(height: 20),
                      _TermsClause(
                        title: AppStrings.termsClause2Title.tr(),
                        body: AppStrings.termsClause2Body.tr(),
                      ),
                      const SizedBox(height: 20),
                      _TermsClause(
                        title: AppStrings.termsClause3Title.tr(),
                        body: AppStrings.termsClause3Body.tr(),
                      ),
                      const SizedBox(height: 20),
                      _TermsClause(
                        title: AppStrings.termsClause4Title.tr(),
                        body: AppStrings.termsClause4Body.tr(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Done Button ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CustomButton(
                    text: AppStrings.btnDone.tr(),
                    onPressed: _onDone,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Single Clause Block
// ─────────────────────────────────────────────────────────────
class _TermsClause extends StatelessWidget {
  final String title;
  final String body;

  const _TermsClause({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}