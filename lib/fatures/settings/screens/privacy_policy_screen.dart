// ============================================
// FILE: lib/fatures/settings/screens/privacy_policy_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import 'widgets/content_page.dart';

/// TODO(api): swap the bundled copy for the CMS/policy endpoint once
/// available, so legal can update it without an app release.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentPage(
      title: AppStrings.privacyPolicy.tr(),
      blocks: [
        ContentParagraph(AppStrings.privacyIntro.tr(), lead: true),
        ContentHeading(AppStrings.privacyCollectTitle.tr()),
        ContentBullets([
          AppStrings.privacyCollect1.tr(),
          AppStrings.privacyCollect2.tr(),
          AppStrings.privacyCollect3.tr(),
        ]),
        ContentHeading(AppStrings.privacyUseTitle.tr()),
        ContentParagraph(AppStrings.privacyUseIntro.tr()),
        ContentBullets([
          AppStrings.privacyUse1.tr(),
          AppStrings.privacyUse2.tr(),
        ]),
      ],
    );
  }
}
