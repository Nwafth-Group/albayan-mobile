// ============================================
// FILE: lib/utils/share_helper.dart
// ============================================
//
// Thin wrapper around share_plus so every "share this item" button in the
// app (book, publisher, author, issue, article, ...) opens the same native
// share sheet instead of each screen wiring per-platform (Facebook/Twitter/
// WhatsApp) buttons by hand.

import 'package:share_plus/share_plus.dart';

class ShareHelper {
  /// Opens the OS share sheet with [text] (e.g. a title + description, and
  /// a link when the backend exposes one). No-ops on blank text.
  static Future<void> share(String text, {String? subject}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(text: trimmed, subject: subject),
    );
  }
}
