// ============================================
// FILE: lib/utils/apple_auth_helper.dart
// ============================================

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

/// Thrown when the user dismisses the Apple sign-in sheet — distinct from a
/// real failure so the caller can stay silent instead of showing an error.
class AppleSignInCancelledException implements Exception {}

/// Result of the Apple → Firebase flow, ready to send to the backend
/// (`POST /reader/auth/apple`).
class AppleSignInResult {
  final String idToken;

  /// Apple only shares the user's name on the very FIRST sign-in for this
  /// app, so these are usually null on later sign-ins.
  final String? firstName;
  final String? lastName;

  const AppleSignInResult({
    required this.idToken,
    this.firstName,
    this.lastName,
  });
}

/// Wraps Sign in with Apple + Firebase Auth into a single call that returns
/// a Firebase ID token. iOS only — the button is hidden on other platforms.
class AppleAuthHelper {
  /// Sign in with Apple is offered on iOS only.
  static bool get isAvailable => Platform.isIOS;

  static Future<AppleSignInResult> signIn() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    late final UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithProvider(provider);
    } on FirebaseAuthException catch (e) {
      if (_isCancel(e)) throw AppleSignInCancelledException();
      rethrow;
    }

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(code: 'failed_to_login');
    }

    final idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw FirebaseAuthException(code: 'missing_id_token');
    }

    // Name: Firebase may put it in displayName or in the raw provider
    // profile — only present on the first authorization.
    final profile = userCredential.additionalUserInfo?.profile ?? const {};
    String? firstName = _nonEmpty(profile['given_name'] ?? profile['firstName']);
    String? lastName = _nonEmpty(profile['family_name'] ?? profile['lastName']);
    final displayName = _nonEmpty(firebaseUser.displayName);
    if (firstName == null && displayName != null) {
      final parts = displayName.split(RegExp(r'\s+'));
      firstName = parts.first;
      lastName ??= parts.length > 1 ? parts.sublist(1).join(' ') : null;
    }

    return AppleSignInResult(
      idToken: idToken,
      firstName: firstName,
      lastName: lastName,
    );
  }

  static bool _isCancel(FirebaseAuthException e) {
    const cancelCodes = {'canceled', 'cancelled', 'web-context-cancelled'};
    if (cancelCodes.contains(e.code)) return true;
    // ASAuthorizationError.canceled == 1001
    final msg = e.message ?? '';
    return msg.contains('1001') || msg.toLowerCase().contains('cancel');
  }

  static String? _nonEmpty(Object? v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }
}
