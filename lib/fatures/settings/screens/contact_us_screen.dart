// ============================================
// FILE: lib/fatures/settings/screens/contact_us_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/api_client.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/link_launcher.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../../widgets/custom_button.dart';
import '../data/datasource/company_remote_data_source.dart';
import '../data/models/company_info_model.dart';
import 'cubit/company_info_cubit.dart';
import 'cubit/contact_us_cubit.dart';
import 'widgets/company_widgets.dart';
import 'widgets/settings_widgets.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = CompanyRemoteDataSourceImpl(ApiService());
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ContactUsCubit(dataSource)),
        BlocProvider(create: (_) => CompanyInfoCubit(dataSource)..load()),
      ],
      child: const _ContactUsView(),
    );
  }
}

class _ContactUsView extends StatefulWidget {
  const _ContactUsView();

  @override
  State<_ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<_ContactUsView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _message = TextEditingController();
  ContactSubject _subject = ContactSubject.inquiry;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    // Prefill from the signed-in reader's profile.
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

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return AppStrings.validationEmailRequired.tr();
    if (!_emailPattern.hasMatch(value)) {
      return AppStrings.validationEmailInvalid.tr();
    }
    return null;
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ContactUsCubit>().send(
      name: _name.text.trim(),
      email: _email.text.trim(),
      subject: _subject,
      message: _message.text.trim(),
    );
  }

  String _subjectLabel(ContactSubject s) {
    switch (s) {
      case ContactSubject.inquiry:
        return AppStrings.contactSubjectInquiry.tr();
      case ContactSubject.complaint:
        return AppStrings.contactSubjectComplaint.tr();
      case ContactSubject.feedback:
        return AppStrings.contactSubjectFeedback.tr();
      case ContactSubject.support:
        return AppStrings.contactSubjectSupport.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactUsCubit, ContactUsState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == ContactUsStatus.sent) {
          // Keep name/email for a follow-up; clear the message itself.
          _message.clear();
          setState(() => _subject = ContactSubject.inquiry);
          AppNavigator.showSnackBar(
            AppStrings.contactMessageSent.tr(),
            backgroundColor: AppColors.success,
          );
        }
        // Failures are already shown by ApiService (incl. field errors).
      },
      child: Scaffold(
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
                validator: _validateEmail,
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.contactSubjectLabel.tr(),
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in ContactSubject.values)
                    _SubjectChip(
                      label: _subjectLabel(s),
                      selected: s == _subject,
                      onTap: () => setState(() => _subject = s),
                    ),
                ],
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
              BlocBuilder<ContactUsCubit, ContactUsState>(
                builder: (context, state) => SizedBox(
                  height: 50,
                  child: CustomButton(
                    text: AppStrings.btnSubmit.tr(),
                    isLoading: state.isSending,
                    onPressed: _submit,
                  ),
                ),
              ),
              BlocBuilder<CompanyInfoCubit, CompanyInfoState>(
                builder: (context, state) {
                  final info = state.info;
                  if (info == null) return const SizedBox.shrink();
                  return _ContactChannels(info: info);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "or reach us on" social buttons, the Call Us button and the contact
/// details card — all driven by the company info.
class _ContactChannels extends StatelessWidget {
  final CompanyInfoModel info;
  const _ContactChannels({required this.info});

  @override
  Widget build(BuildContext context) {
    final socials = <Widget>[
      if (info.twitter != null)
        _SocialButton(
          icon: HugeIcons.strokeRoundedNewTwitter,
          color: Colors.black,
          onTap: () => LinkLauncher.openUrl(info.twitter),
        ),
      if (info.whatsapp != null)
        _SocialButton(
          icon: HugeIcons.strokeRoundedWhatsapp,
          color: const Color(0xFF25D366),
          onTap: () => LinkLauncher.whatsapp(info.whatsapp),
        ),
      if (info.instagram != null)
        _SocialButton(
          icon: HugeIcons.strokeRoundedInstagram,
          color: const Color(0xFFE1306C),
          onTap: () => LinkLauncher.openUrl(info.instagram),
        ),
      if (info.facebook != null)
        _SocialButton(
          icon: HugeIcons.strokeRoundedFacebook01,
          color: const Color(0xFF1877F2),
          onTap: () => LinkLauncher.openUrl(info.facebook),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (socials.isNotEmpty || info.phone != null) ...[
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
        ],
        if (socials.isNotEmpty)
          Row(
            children: [
              for (var i = 0; i < socials.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                socials[i],
              ],
            ],
          ),
        if (info.phone != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => LinkLauncher.call(info.phone),
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
        const SizedBox(height: 16),
        CompanyDetailsCard(
          info: info,
          title: AppStrings.contactDetailsTitle.tr(),
          // Phone + WhatsApp already have buttons above.
          showPhones: false,
        ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SubjectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : settingsBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
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
