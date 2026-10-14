// ============================================
// FILE: lib/fatures/settings/screens/widgets/company_widgets.dart
// ============================================
//
// Company contact details from `/public/company-info`, shared by the
// Contact Us and About Us screens.

import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../utils/constants.dart';
import '../../../../utils/link_launcher.dart';
import '../../data/models/company_info_model.dart';
import 'settings_widgets.dart';

/// Card of tappable contact rows; rows the API didn't fill are left out.
class CompanyDetailsCard extends StatelessWidget {
  final CompanyInfoModel info;
  final String title;

  /// Also show phone / WhatsApp rows (the Contact screen has its own
  /// buttons for those, so it turns this off).
  final bool showPhones;

  /// Also show the company name and VAT number (About screen).
  final bool showCompany;

  const CompanyDetailsCard({
    super.key,
    required this.info,
    required this.title,
    this.showPhones = true,
    this.showCompany = false,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final rows = <Widget>[
      if (showCompany && info.name(lang) != null)
        _DetailRow(
          icon: HugeIcons.strokeRoundedBuilding03,
          label: info.name(lang)!,
        ),
      if (showPhones && info.phone != null)
        _DetailRow(
          icon: HugeIcons.strokeRoundedCall02,
          label: info.phone!,
          caption: AppStrings.phoneLabel.tr(),
          ltr: true,
          onTap: () => LinkLauncher.call(info.phone),
        ),
      if (showPhones && info.whatsapp != null)
        _DetailRow(
          icon: HugeIcons.strokeRoundedWhatsapp,
          label: info.whatsapp!,
          caption: AppStrings.whatsappLabel.tr(),
          ltr: true,
          onTap: () => LinkLauncher.whatsapp(info.whatsapp),
        ),
      if (info.email != null)
        _DetailRow(
          icon: HugeIcons.strokeRoundedMail01,
          label: info.email!,
          caption: AppStrings.labelEmail.tr(),
          ltr: true,
          onTap: () => LinkLauncher.email(info.email),
        ),
      if (info.website != null)
        _DetailRow(
          icon: HugeIcons.strokeRoundedGlobe02,
          label: info.website!.replaceFirst(RegExp(r'^https?://'), ''),
          caption: AppStrings.websiteLabel.tr(),
          ltr: true,
          onTap: () => LinkLauncher.openUrl(info.website),
        ),
      if (info.address != null)
        _DetailRow(
          icon: HugeIcons.strokeRoundedLocation01,
          label: info.address!,
          caption: AppStrings.addressLabel.tr(),
        ),
      if (showCompany && info.vatNumber != null)
        _DetailRow(
          icon: HugeIcons.strokeRoundedInvoice01,
          label: info.vatNumber!,
          caption: AppStrings.vatNumberLabel.tr(),
          ltr: true,
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: settingsCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          ...rows,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String? caption;

  /// Numbers, emails and URLs read left-to-right even in Arabic.
  final bool ltr;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.caption,
    this.ltr = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.accentPale,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(icon: icon, color: AppColors.primary, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null)
                    Text(
                      caption!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  Text(
                    label,
                    textDirection: ltr ? ui.TextDirection.ltr : null,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                color: AppColors.textLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
