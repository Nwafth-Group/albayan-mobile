// ============================================
// FILE: lib/fatures/settings/screens/contact_us_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../../widgets/custom_button.dart';
import 'widgets/settings_widgets.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _message = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = SharedPrefHelper.getUser();
    _name = TextEditingController(text: user?.displayName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired.tr() : null;

  void _comingSoon() => Helpers.showError(AppStrings.featureComingSoon.tr());

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // TODO(api): send name / email / message to the contact endpoint.
    _comingSoon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(title: AppStrings.contactUs.tr()),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            SettingsField(
              label: AppStrings.fullName.tr(),
              hint: AppStrings.fullName.tr(),
              controller: _name,
              validator: _required,
            ),
            const SizedBox(height: 14),
            SettingsField(
              label: AppStrings.labelEmail.tr(),
              hint: AppStrings.hintEmail.tr(),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: _required,
            ),
            const SizedBox(height: 14),
            SettingsField(
              label: AppStrings.messageLabel.tr(),
              hint: AppStrings.writeMessageHint.tr(),
              controller: _message,
              maxLines: 6,
              validator: _required,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: CustomButton(
                text: AppStrings.btnSubmit.tr(),
                onPressed: _submit,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.textLight)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    AppStrings.orContinueWith.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.textLight)),
              ],
            ),
            const SizedBox(height: 20),
            // TODO: open the real social / phone links (needs the URLs and
            // a url_launcher dependency).
            Row(
              children: [
                _SocialButton(
                  icon: HugeIcons.strokeRoundedNewTwitter,
                  color: Colors.black,
                  onTap: _comingSoon,
                ),
                const SizedBox(width: 8),
                _SocialButton(
                  icon: HugeIcons.strokeRoundedWhatsapp,
                  color: const Color(0xFF25D366),
                  onTap: _comingSoon,
                ),
                const SizedBox(width: 8),
                _SocialButton(
                  icon: HugeIcons.strokeRoundedInstagram,
                  color: const Color(0xFFE1306C),
                  onTap: _comingSoon,
                ),
                const SizedBox(width: 8),
                _SocialButton(
                  icon: HugeIcons.strokeRoundedFacebook01,
                  color: const Color(0xFF1877F2),
                  onTap: _comingSoon,
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _comingSoon,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: settingsBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedCallRinging02,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.callUs.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: settingsBorder),
          ),
          child: Center(
            child: HugeIcon(icon: icon, color: color, size: 26),
          ),
        ),
      ),
    );
  }
}
