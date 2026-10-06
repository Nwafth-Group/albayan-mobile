// ============================================
// FILE: lib/utils/link_launcher.dart
// ============================================
//
// Opens external links (websites, social pages, phone, email, WhatsApp) and
// shows a translated message when the device can't handle one.

import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'helpers.dart';

class LinkLauncher {
  LinkLauncher._();

  /// A website / social page, opened in the browser or its app.
  static Future<void> openUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final raw = url.trim();
    final uri = Uri.tryParse(raw.contains('://') ? raw : 'https://$raw');
    await _launch(uri);
  }

  static Future<void> call(String? phone) async {
    final digits = _digits(phone);
    if (digits.isEmpty) return;
    await _launch(Uri(scheme: 'tel', path: digits));
  }

  static Future<void> email(String? address) async {
    if (address == null || address.trim().isEmpty) return;
    await _launch(Uri(scheme: 'mailto', path: address.trim()));
  }

  /// Opens a WhatsApp chat. wa.me needs the international number, so a
  /// local Saudi number (05XXXXXXXX) is converted to 9665XXXXXXXX.
  static Future<void> whatsapp(String? phone) async {
    final number = internationalNumber(phone);
    if (number.isEmpty) return;
    await _launch(Uri.parse('https://wa.me/$number'));
  }

  static String internationalNumber(String? phone) {
    var digits = _digits(phone).replaceAll('+', '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '966${digits.substring(1)}';
    return digits;
  }

  static String _digits(String? s) =>
      (s ?? '').replaceAll(RegExp(r'[^0-9+]'), '');

  static Future<void> _launch(Uri? uri) async {
    var opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened) Helpers.showError(AppStrings.cannotOpenLink.tr());
  }
}
