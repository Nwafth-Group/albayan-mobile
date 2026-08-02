// ============================================
// FILE: lib/fatures/auth/screens/cubit/auth_cubit.dart
// ============================================

import 'package:albayan/fatures/auth/data/datasource/auth_remote_datasource.dart';
import 'package:albayan/fatures/auth/data/models/user_model.dart';
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
      emit(CountriesError(e.toString()));
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
      emit(LoginError(e.toString()));
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
      emit(LoginError(e.toString()));
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
      emit(RegisterError(e.toString()));
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
      emit(RegisterError(e.toString()));
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
        emit(const OtpError('Invalid response from server.'));
        return;
      }
      final user = UserModel.fromJson(userJson);
      await SharedPrefHelper.saveToken(token);
      await SharedPrefHelper.saveUser(user);
      emit(OtpVerified(user));
    } catch (e) {
      emit(OtpError(e.toString()));
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
      emit(OtpResendError(e.toString()));
    }
  }

  // ── Forgot Password: Request OTP ────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    emit(const ForgotPasswordLoading());
    try {
      await _dataSource.forgotPassword(email: email);
      emit(ForgotPasswordOtpSent(email));
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
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
        emit(const ForgotPasswordOtpError('Invalid response from server.'));
        return;
      }
      emit(ForgotPasswordOtpVerified(resetToken));
    } catch (e) {
      emit(ForgotPasswordOtpError(e.toString()));
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
      emit(ResetPasswordError(e.toString()));
    }
  }

  // ── Get Profile ───────────────────────────────────────────────
  Future<void> getProfile() async {
    emit(const ProfileLoading());
    try {
      final response = await _dataSource.getProfile();
      final userJson = response['data'] as Map<String, dynamic>?;
      if (userJson == null) {
        emit(const ProfileError('Invalid response from server.'));
        return;
      }
      final user = UserModel.fromJson(userJson);
      await SharedPrefHelper.saveUser(user);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    emit(const LogoutLoading());
    try {
      await _dataSource.logout();
      await SharedPrefHelper.logout();
      emit(const LogoutSuccess());
    } catch (e) {
      // Even if the API call fails, clear local data and log out
      await SharedPrefHelper.logout();
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
        emit(const LoginError('Invalid response from server.'));
        return;
      }

      final user = UserModel.fromJson(userJson);

      await SharedPrefHelper.saveToken(token);
      await SharedPrefHelper.saveUser(user);

      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}