// ============================================
// FILE: lib/fatures/settings/screens/terms_conditions_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../data/models/policy_model.dart';
import 'policy_screen.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PolicyScreen(
      type: PolicyType.terms,
      title: AppStrings.termsConditions.tr(),
    );
  }
}
