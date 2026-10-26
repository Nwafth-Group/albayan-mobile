// ============================================
// FILE: lib/fatures/settings/screens/redeem_gift_screen.dart
// ============================================

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import 'widgets/settings_widgets.dart';

class RedeemGiftScreen extends StatefulWidget {
  const RedeemGiftScreen({super.key});

  @override
  State<RedeemGiftScreen> createState() => _RedeemGiftScreenState();
}

class _RedeemGiftScreenState extends State<RedeemGiftScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) _code.text = text;
  }

  void _redeem() {
    if (_code.text.trim().isEmpty) {
      Helpers.showError(AppStrings.fieldRequired.tr());
      return;
    }
    // TODO(api): redeem `_code.text` (the checkout's `gift_code`) once the
    // redeem endpoint exists.
    Helpers.showError(AppStrings.featureComingSoon.tr());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SettingsAppBar(
        title: AppStrings.redeemGift.tr(),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
        children: [
          const Center(child: GiftIllustration()),
          const SizedBox(height: 40),
          SettingsField(
            label: AppStrings.giftCode.tr(),
            hint: AppStrings.enterCode.tr(),
            controller: _code,
            borderColor: AppColors.accentLight,
            suffix: IconButton(
              onPressed: _paste,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedCopy01,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SettingsBottomButton(
        text: AppStrings.redeem.tr(),
        onPressed: _redeem,
      ),
    );
  }
}

/// The gift box + confetti illustration from the Redeem Gift design,
/// drawn with plain widgets (no image asset).
class GiftIllustration extends StatelessWidget {
  const GiftIllustration({super.key});

  static const _box = Color(0xFFF2B84B);
  static const _lid = Color(0xFFE8744A);
  static const _ribbon = Color(0xFFA8322D);

  @override
  Widget build(BuildContext context) {
    Widget dot(double size, Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return SizedBox(
      width: 230,
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Confetti.
          Positioned(left: 14, top: 4, child: dot(10, _box)),
          Positioned(left: 36, top: 14, child: dot(6, _box)),
          Positioned(left: 24, top: 60, child: dot(11, _lid)),
          Positioned(right: 16, top: 84, child: dot(11, Colors.grey.shade400)),
          Positioned(
            left: 38,
            bottom: 34,
            child: dot(10, AppColors.accentPale),
          ),
          Positioned(left: 118, bottom: 6, child: dot(5, Colors.blueGrey)),
          Positioned(left: 134, bottom: 0, child: dot(10, _box)),
          Positioned(
            right: 16,
            top: 0,
            child: Transform.rotate(
              angle: -0.6,
              child: const Icon(Icons.gesture, color: Colors.teal, size: 30),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 48,
            child: Icon(Icons.gesture, color: Colors.grey.shade400, size: 30),
          ),

          // Shadow.
          Positioned(
            left: 60,
            right: 50,
            bottom: 22,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          // Box body + vertical ribbon.
          Positioned(
            left: 64,
            bottom: 26,
            child: Container(
              width: 100,
              height: 96,
              color: _box,
              alignment: Alignment.center,
              child: Container(width: 18, color: _ribbon),
            ),
          ),

          // Lid + ribbon.
          Positioned(
            left: 56,
            bottom: 116,
            child: Container(
              width: 116,
              height: 24,
              decoration: BoxDecoration(
                color: _lid,
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: Container(width: 18, color: _ribbon),
            ),
          ),

          // Bow.
          Positioned(
            left: 86,
            bottom: 136,
            child: Row(
              children: [
                Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: 30,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _ribbon.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: 0.5,
                  child: Container(
                    width: 30,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _ribbon.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(left: 107, bottom: 134, child: dot(14, _ribbon)),
        ],
      ),
    );
  }
}
