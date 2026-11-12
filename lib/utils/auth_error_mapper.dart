// ============================================
// FILE: lib/utils/auth_error_mapper.dart
// ============================================

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'constants.dart';

/// Turns any error thrown during auth into a short, translated message a
/// regular user can understand — never raw Firebase/Apple/Google text like
/// "[firebase_auth/unknown] ... AuthorizationError error 1000".
class AuthErrorMapper {
  static String message(Object error) {
    // ApiService already throws ready-to-show (translated) strings.
    if (error is String) return error;

    if (error is FirebaseAuthException) return _firebase(error);
    if (error is GoogleSignInException) {
      return AppStrings.authErrorSocialFailed.tr();
    }
    if (error is SocketException) return AppStrings.errorNoInternet.tr();

    return AppStrings.errorUnexpected.tr();
  }

  static String _firebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return AppStrings.errorNoInternet.tr();
      case 'user-disabled':
        return AppStrings.authErrorAccountDisabled.tr();
      case 'account-exists-with-different-credential':
      case 'credential-already-in-use':
      case 'email-already-in-use':
        return AppStrings.authErrorAccountExists.tr();
      case 'too-many-requests':
        return AppStrings.authErrorTooManyRequests.tr();
    }

    // Apple (ASAuthorizationError) errors come through as code "unknown"
    // with the Apple error inside the message. 1000 = not signed in to an
    // Apple Account on the device (or the user closed that prompt).
    final msg = e.message ?? '';
    if (msg.contains('AuthorizationError')) {
      return msg.contains('1000')
          ? AppStrings.authErrorAppleUnavailable.tr()
          : AppStrings.authErrorSocialFailed.tr();
    }

    return AppStrings.authErrorSocialFailed.tr();
  }
}
