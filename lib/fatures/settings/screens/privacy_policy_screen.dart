// ============================================
// FILE: lib/fatures/settings/screens/privacy_policy_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../data/models/policy_model.dart';
import 'policy_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PolicyScreen(
      type: PolicyType.privacy,
      title: AppStrings.privacyPolicy.tr(),
    );
  }
}
