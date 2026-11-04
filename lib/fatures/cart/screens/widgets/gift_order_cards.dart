// ============================================
// FILE: lib/fatures/cart/screens/widgets/gift_order_cards.dart
// ============================================
//
// "Gift Code" and "Gift Message" cards shown after a gift checkout and in
// a gift order's details.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../utils/app_navigator.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/link_launcher.dart';
import '../../../../utils/share_helper.dart';
import '../../../settings/screens/widgets/settings_widgets.dart';

const _titleStyle = TextStyle(fontSize: 16, color: AppColors.textPrimary);
const _bodyStyle = TextStyle(
  fontSize: 13,
  color: AppColors.textPrimary,
  height: 1.6,
);

class _CardHeader extends StatelessWidget {
  final String title;
  final List<List<dynamic>> icon;
  final VoidCallback onTap;

  const _CardHeader({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: _titleStyle)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: HugeIcon(icon: icon, color: AppColors.primary, size: 24),
          ),
        ),
      ],
    );
  }
}

/// The redeemable code with a copy button.
class GiftCodeCard extends StatelessWidget {
  final String code;

  const GiftCodeCard({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: settingsCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.giftCode.tr(), style: _titleStyle),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  AppNavigator.showSnackBar(AppStrings.readerCopied.tr());
                },
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCopy01,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The API's `share_message`, with its links tappable and the store links
/// pulled out under "Get the App". The share button sends the message as-is.
class GiftMessageCard extends StatelessWidget {
  final String message;

  const GiftMessageCard({super.key, required this.message});

  static final _url = RegExp(r'https?://\S+');

  /// "Google Play: https://..." / "App Store: https://..." lines.
  static final _storeLine = RegExp(
    r'^\s*(google\s*play|play\s*store|android|app\s*store|ios|apple)\s*:\s*(https?://\S+)\s*$',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    String? android;
    String? ios;
    final body = <String>[];
    for (final line in message.split('\n')) {
      final m = _storeLine.firstMatch(line);
      if (m == null) {
        body.add(line);
        continue;
      }
      final store = m.group(1)!.toLowerCase();
      if (store.contains('google') ||
          store.contains('play') ||
          store == 'android') {
        android = m.group(2);
      } else {
        ios = m.group(2);
      }
    }
    final text = body.join('\n').trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: settingsCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: AppStrings.giftMessage.tr(),
            icon: HugeIcons.strokeRoundedShare08,
            onTap: () => ShareHelper.share(message),
          ),
          const SizedBox(height: 10),
          if (text.isNotEmpty) _LinkText(text),
          if (android != null || ios != null) ...[
            const SizedBox(height: 14),
            Text(AppStrings.getTheApp.tr(), style: _titleStyle),
            const SizedBox(height: 8),
            if (android != null)
              _StoreLink(label: AppStrings.androidLink.tr(), url: android),
            if (ios != null)
              _StoreLink(label: AppStrings.iosLink.tr(), url: ios),
          ],
        ],
      ),
    );
  }
}

/// Plain text with every URL in it primary-coloured and tappable.
class _LinkText extends StatelessWidget {
  final String text;

  const _LinkText(this.text);

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    var start = 0;
    for (final m in GiftMessageCard._url.allMatches(text)) {
      if (m.start > start) {
        spans.add(TextSpan(text: text.substring(start, m.start)));
      }
      final url = m.group(0)!;
      spans.add(_linkSpan(url));
      start = m.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));

    return Text.rich(TextSpan(style: _bodyStyle, children: spans));
  }
}

TextSpan _linkSpan(String url) => TextSpan(
  text: url,
  style: const TextStyle(color: AppColors.primary),
  recognizer: TapGestureRecognizer()..onTap = () => LinkLauncher.openUrl(url),
);

class _StoreLink extends StatelessWidget {
  final String label;
  final String url;

  const _StoreLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          style: _bodyStyle,
          children: [TextSpan(text: '$label : '), _linkSpan(url)],
        ),
      ),
    );
  }
}
