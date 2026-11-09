// ============================================
// FILE: lib/utils/share_helper.dart
// ============================================
//
// Thin wrapper around share_plus so every "share this item" button in the
// app (book, publisher, author, issue, article, ...) opens the same native
// share sheet instead of each screen wiring per-platform (Facebook/Twitter/
// WhatsApp) buttons by hand.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'app_navigator.dart';
import 'constants.dart';

class ShareHelper {
  /// Opens the OS share sheet with [text] (e.g. a title + description, and
  /// a link when the backend exposes one). No-ops on blank text.
  ///
  /// Pass the tapped widget's [context] to anchor the iPad share popover
  /// to it; otherwise it's anchored to the middle of the screen.
  static Future<void> share(
    String text, {
    String? subject,
    BuildContext? context,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: trimmed,
          subject: subject,
          sharePositionOrigin: _origin(context),
        ),
      );
    } catch (e) {
      debugPrint('Share failed: $e');
      AppNavigator.showErrorSnackBar(AppStrings.somethingWentWrong.tr());
    }
  }

  /// iPad (and recent iOS) reject a share without a non-zero anchor rect.
  static Rect? _origin(BuildContext? context) {
    final box = (context ?? AppNavigator.context)?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    if (context != null) return box.localToGlobal(Offset.zero) & box.size;
    return Rect.fromCenter(
      center: box.localToGlobal(box.size.center(Offset.zero)),
      width: 1,
      height: 1,
    );
  }
}
