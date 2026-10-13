// ============================================
// FILE: lib/utils/google_auth_helper.dart
// ============================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'constants.dart';

/// Thrown when the user dismisses the Google account picker instead of
/// picking an account — distinct from a real failure so the caller can
/// stay silent instead of showing an error.
class GoogleSignInCancelledException implements Exception {}

/// Wraps Google Sign-In + Firebase Auth into a single call that returns a
/// Firebase ID token ready to send to the backend (`POST /reader/auth/google`).
class GoogleAuthHelper {
  static bool _initialized = false;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      serverClientId: SocialAuthConfig.googleServerClientId,
    );
    _initialized = true;
  }

  /// Runs the full Google → Firebase sign-in flow and returns the Firebase
  /// ID token for the signed-in user. Throws [GoogleSignInCancelledException]
  /// if the user closes the account picker without choosing an account.
  static Future<String> signIn() async {
    await _ensureInitialized();

    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw GoogleSignInCancelledException();
      }
      rethrow;
    }

    final authorization = await googleUser.authorizationClient
        .authorizationForScopes(['email', 'profile']);

    final credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
      accessToken: authorization?.accessToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(code: 'failed_to_login');
    }

    final idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw FirebaseAuthException(code: 'missing_id_token');
    }
    return idToken;
  }

  /// Signs out of both Google and Firebase — call on app logout so the
  /// next "Continue with Google" always shows the account picker.
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Not signed in via Google (e.g. email/password account) — ignore.
    }
  }
}
