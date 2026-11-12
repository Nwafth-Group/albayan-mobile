// ============================================
// FILE: lib/fatures/auth/screens/cubit/auth_cubit.dart
// ============================================

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/data/models/user_model.dart';
import 'package:albayan/utils/apple_auth_helper.dart';
import 'package:albayan/utils/auth_error_mapper.dart';
import 'package:albayan/utils/google_auth_helper.dart';
import 'package:albayan/utils/shared_pref_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRemoteDataSource _dataSource;

  AuthCubit(this._dataSource) : super(const AuthInitial());

  // ── Fetch Countries ───────────────────────────────────────────
  Future<void> fetchCountries({String search = ''}) async {
    emit(const CountriesLoading());
    try {
      final countries = await _dataSource.getCountries(search: search);
      emit(CountriesLoaded(countries));
    } catch (e) {
      emit(CountriesError(AuthErrorMapper.message(e)));
    }
  }

  // ── Login (Email) ─────────────────────────────────────────────
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const LoginLoading());
    try {
      final response = await _dataSource.loginWithEmail(
        email:    email,
        password: password,
      );
      await _handleAuthResponse(response);
    } catch (e) {
      emit(LoginError(AuthErrorMapper.message(e)));
    }
  }

  // ── Login (Mobile) ────────────────────────────────────────────
  Future<void> loginWithMobile({required String mobileNumber}) async {
    emit(const LoginLoading());
    try {
      final response = await _dataSource.loginWithMobile(
        mobileNumber: mobileNumber,
      );
      await _handleAuthResponse(response, mobileNumber: mobileNumber);
    } catch (e) {
      emit(LoginError(AuthErrorMapper.message(e)));
    }
  }

  // ── Login (Google) ─────────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    emit(const GoogleLoginLoading());
    try {
      final idToken = await GoogleAuthHelper.signIn();
      final response = await _dataSource.loginWithGoogle(idToken: idToken);
      await _handleAuthResponse(response);
    } on GoogleSignInCancelledException {
      emit(const GoogleLoginCancelled());
    } catch (e) {
      emit(LoginError(AuthErrorMapper.message(e)));
    }
  }

  // ── Login (Apple, iOS only) ───────────────────────────────────
  Future<void> loginWithApple() async {
    emit(const AppleLoginLoading());
    try {
      final result = await AppleAuthHelper.signIn();
      final response = await _dataSource.loginWithApple(
        idToken:   result.idToken,
        firstName: result.firstName,
        lastName:  result.lastName,
      );
      await _handleAuthResponse(response);
    } on AppleSignInCancelledException {
      emit(const AppleLoginCancelled());
    } catch (e) {
      emit(LoginError(AuthErrorMapper.message(e)));
    }
  }

  // ── Register (Email) ──────────────────────────────────────────
  Future<void> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String countryId,
    required String password,
    required String passwordConfirmation,
    required bool termsAccepted,
    String defaultLanguage = 'en',
  }) async {
    emit(const RegisterLoading());
    try {
      await _dataSource.register(
        firstName:            firstName,
        lastName:             lastName,
        email:                email,
        countryId:            countryId,
        termsAccepted:        termsAccepted,
        defaultLanguage:      defaultLanguage,
        password:             password,
        passwordConfirmation: passwordConfirmation,
      );
      emit(RegisterSuccess(recipient: email, isEmail: true));
    } catch (e) {
      emit(RegisterError(AuthErrorMapper.message(e)));
    }
  }

  // ── Register (Mobile) ─────────────────────────────────────────
  Future<void> registerWithMobile({
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String countryId,
    required bool termsAccepted,
    String defaultLanguage = 'en',
  }) async {
    emit(const RegisterLoading());
    try {
      await _dataSource.register(
        firstName:       firstName,
        lastName:        lastName,
        mobileNumber:    mobileNumber,
        countryId:       countryId,
        termsAccepted:   termsAccepted,
        defaultLanguage: defaultLanguage,
      );
      emit(RegisterSuccess(recipient: mobileNumber, isEmail: false));
    } catch (e) {
      emit(RegisterError(AuthErrorMapper.message(e)));
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────
  Future<void> verifyOtp({
    String? email,
    String? mobileNumber,
    required String otpCode,
  }) async {
    emit(const OtpLoading());
    try {
      final response = await _dataSource.verifyOtp(
        email:        email,
        mobileNumber: mobileNumber,
        otpCode:      otpCode,
      );
      final data     = response['data'] as Map<String, dynamic>?;
      final token    = data?['token']   as String?;
      final userJson = data?['user']    as Map<String, dynamic>?;

      if (token == null || userJson == null) {
        emit(OtpError(AppStrings.errorInvalidResponse.tr()));
        return;
      }
      final user = UserModel.fromJson(userJson);
      await SharedPrefHelper.saveToken(token);
      await SharedPrefHelper.saveUser(user);
      emit(OtpVerified(user));
    } catch (e) {
      emit(OtpError(AuthErrorMapper.message(e)));
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────
  Future<void> resendOtp({
    String? email,
    String? mobileNumber,
  }) async {
    emit(const OtpResendLoading());
    try {
      await _dataSource.resendOtp(
        email:        email,
        mobileNumber: mobileNumber,
      );
      emit(const OtpResendSuccess());
    } catch (e) {
      emit(OtpResendError(AuthErrorMapper.message(e)));
    }
  }

  // ── Forgot Password: Request OTP ────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    emit(const ForgotPasswordLoading());
    try {
      await _dataSource.forgotPassword(email: email);
      emit(ForgotPasswordOtpSent(email));
    } catch (e) {
      emit(ForgotPasswordError(AuthErrorMapper.message(e)));
    }
  }

  // ── Forgot Password: Verify OTP ─────────────────────────────────
  Future<void> verifyForgotPasswordOtp({
    required String email,
    required String otpCode,
  }) async {
    emit(const ForgotPasswordOtpLoading());
    try {
      final response = await _dataSource.verifyForgotPasswordOtp(
        email:   email,
        otpCode: otpCode,
      );
      final data       = response['data'] as Map<String, dynamic>?;
      final resetToken = data?['reset_token'] as String?;

      if (resetToken == null) {
        emit(ForgotPasswordOtpError(AppStrings.errorInvalidResponse.tr()));
        return;
      }
      emit(ForgotPasswordOtpVerified(resetToken));
    } catch (e) {
      emit(ForgotPasswordOtpError(AuthErrorMapper.message(e)));
    }
  }

  // ── Reset Password ───────────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(const ResetPasswordLoading());
    try {
      await _dataSource.resetPassword(
        email:                 email,
        resetToken:            resetToken,
        password:              password,
        passwordConfirmation:  passwordConfirmation,
      );
      emit(const ResetPasswordSuccess());
    } catch (e) {
      emit(ResetPasswordError(AuthErrorMapper.message(e)));
    }
  }

  // ── Get Profile ───────────────────────────────────────────────
  Future<void> getProfile() async {
    emit(const ProfileLoading());
    try {
      final response = await _dataSource.getProfile();
      final userJson = response['data'] as Map<String, dynamic>?;
      if (userJson == null) {
        emit(ProfileError(AppStrings.errorInvalidResponse.tr()));
        return;
      }
      final user = UserModel.fromJson(userJson);
      await SharedPrefHelper.saveUser(user);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(AuthErrorMapper.message(e)));
    }
  }

  // ── Update Profile ────────────────────────────────────────────
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String mobileNumber,
    String? countryId,
    File? image,
  }) async {
    final previousEmail = SharedPrefHelper.getUser()?.email ?? '';
    emit(const ProfileUpdateLoading());
    try {
      final response = await _dataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobileNumber: mobileNumber,
        countryId: countryId,
        image: image,
      );
      final data = response['data'];
      // The user may come back directly in `data` or nested in `data.user`.
      final userJson = data is Map<String, dynamic>
          ? (data['user'] as Map<String, dynamic>?) ??
                (data.containsKey('id') ? data : null)
          : null;

      UserModel? user;
      if (userJson != null) {
        user = UserModel.fromJson(userJson);
      } else {
        // Fall back to a fresh fetch when the update response has no user.
        final profile = await _dataSource.getProfile();
        final profileJson = profile['data'] as Map<String, dynamic>?;
        if (profileJson != null) user = UserModel.fromJson(profileJson);
      }
      if (user == null) {
        emit(ProfileUpdateError(AppStrings.errorInvalidResponse.tr()));
        return;
      }
      await SharedPrefHelper.saveUser(user);

      final emailChanged =
          email.trim().isNotEmpty &&
          email.trim().toLowerCase() != previousEmail.trim().toLowerCase();
      final verificationRequired =
          emailChanged ||
          (data is Map && data['status'] == 'verification_required');
      emit(
        ProfileUpdated(user, emailVerificationRequired: verificationRequired),
      );
    } catch (e) {
      emit(ProfileUpdateError(AuthErrorMapper.message(e)));
    }
  }

  // ── Verify Profile Email ──────────────────────────────────────
  Future<void> verifyProfileEmail({required String otpCode}) async {
    emit(const ProfileEmailVerifyLoading());
    try {
      await _dataSource.verifyProfileEmail(otpCode: otpCode);
      // Refresh the cached user so the new email shows everywhere.
      try {
        final profile = await _dataSource.getProfile();
        final userJson = profile['data'] as Map<String, dynamic>?;
        if (userJson != null) {
          await SharedPrefHelper.saveUser(UserModel.fromJson(userJson));
        }
      } catch (_) {}
      emit(const ProfileEmailVerified());
    } catch (e) {
      emit(ProfileEmailVerifyError(AuthErrorMapper.message(e)));
    }
  }

  // ── Resend Profile Email OTP ──────────────────────────────────
  Future<void> resendProfileEmailOtp() async {
    emit(const OtpResendLoading());
    try {
      await _dataSource.resendProfileEmailOtp();
      emit(const OtpResendSuccess());
    } catch (e) {
      emit(OtpResendError(AuthErrorMapper.message(e)));
    }
  }

  // ── Change Password ───────────────────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    emit(const ChangePasswordLoading());
    try {
      await _dataSource.changePassword(
        currentPassword:         currentPassword,
        newPassword:             newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      emit(const ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordError(AuthErrorMapper.message(e)));
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    emit(const LogoutLoading());
    try {
      await _dataSource.logout();
      await SharedPrefHelper.logout();
      await GoogleAuthHelper.signOut();
      emit(const LogoutSuccess());
    } catch (e) {
      // Even if the API call fails, clear local data and log out
      await SharedPrefHelper.logout();
      await GoogleAuthHelper.signOut();
      emit(const LogoutSuccess());
    }
  }

  // ── Shared helper: parse login/verify response ────────────────
  Future<void> _handleAuthResponse(
      Map<String, dynamic> response, {
        String? mobileNumber,
      }) async {
    try {
      final data = response['data'] as Map<String, dynamic>?;

      final verificationStatus = data?['status'];

      if (verificationStatus == 'verification_required') {
        emit(LoginOtpRequired(mobileNumber ?? ''));
        return;
      }

      final token = data?['token'] as String?;
      final userJson = data?['user'] as Map<String, dynamic>?;

      if (token == null || userJson == null) {
        emit(LoginError(AppStrings.errorInvalidResponse.tr()));
        return;
      }

      final user = UserModel.fromJson(userJson);

      await SharedPrefHelper.saveToken(token);
      await SharedPrefHelper.saveUser(user);

      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginError(AuthErrorMapper.message(e)));
    }
  }
}