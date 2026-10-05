// ============================================
// FILE: lib/fatures/settings/screens/terms_conditions_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import 'widgets/content_page.dart';

/// Same clauses as the registration terms dialog (`TermsScreen`).
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentPage(
      title: AppStrings.termsConditions.tr(),
      blocks: [
        for (final (title, body) in const [
          (AppStrings.termsClause1Title, AppStrings.termsClause1Body),
          (AppStrings.termsClause2Title, AppStrings.termsClause2Body),
          (AppStrings.termsClause3Title, AppStrings.termsClause3Body),
          (AppStrings.termsClause4Title, AppStrings.termsClause4Body),
        ]) ...[ContentHeading(title.tr()), ContentParagraph(body.tr())],
      ],
    );
  }
}
