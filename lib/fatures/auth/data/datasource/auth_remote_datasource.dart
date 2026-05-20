
// ============================================
// FILE: lib/features/auth/data/datasources/auth_remote_datasource.dart
// ============================================

import '../../../../utils/api_client.dart';
import '../../../../utils/constants.dart';
import '../models/country_model.dart';

class AuthRemoteDataSource {
  final ApiService _api;

  AuthRemoteDataSource(this._api);

  // ── Get Countries ─────────────────────────────────────────────
  Future<List<CountryModel>> getCountries({String search = ''}) async {
    final response = await _api.get(
      ApiConstants.getCountries,
      queryParameters: {'search': search},
    );

    final items = response['data']['items'] as List<dynamic>;
    return items
        .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Login (Email) ─────────────────────────────────────────────
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _api.post(ApiConstants.login, data: {
      'email':    email,
      'password': password,
    });
  }

  // ── Login (Mobile) ────────────────────────────────────────────
  Future<Map<String, dynamic>> loginWithMobile({
    required String mobileNumber,
  }) async {
    return _api.post(ApiConstants.login, data: {
      'mobile_number': mobileNumber,
    });
  }

  // ── Register ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    String? email,
    String? mobileNumber,
    required String countryId,
    required bool termsAccepted,
    String defaultLanguage = 'en',
    String? password,
    String? passwordConfirmation,
  }) async {
    final body = <String, dynamic>{
      'first_name':     firstName,
      'last_name':      lastName,
      'country_id':     countryId,
      'terms_accepted': termsAccepted,
      'default_language': defaultLanguage,
    };

    if (email != null && email.isNotEmpty) {
      body['email']                 = email;
      body['password']              = password;
      body['password_confirmation'] = passwordConfirmation;
    }

    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      body['mobile_number'] = mobileNumber;
    }

    return _api.post(ApiConstants.register, data: body);
  }

  // ── Verify OTP ────────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp({
    String? email,
    String? mobileNumber,
    required String otpCode,
  }) async {
    final body = <String, dynamic>{'otp_code': otpCode};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      body['mobile_number'] = mobileNumber;
    }
    return _api.post(ApiConstants.verifyOtp, data: body);
  }

  // ── Resend OTP ────────────────────────────────────────────────
  Future<Map<String, dynamic>> resendOtp({
    String? email,
    String? mobileNumber,
  }) async {
    final body = <String, dynamic>{};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      body['mobile_number'] = mobileNumber;
    }
    return _api.post(ApiConstants.resendOtp, data: body);
  }

  // ── Get Profile ───────────────────────────────────────────────
  Future<Map<String, dynamic>> getProfile() async {
    return _api.get(ApiConstants.profile);
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    await _api.post(ApiConstants.logout);
  }
}