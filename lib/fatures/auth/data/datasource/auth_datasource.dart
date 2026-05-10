import 'package:albayan/utils/constants.dart';
import 'package:albayan/utils/helpers.dart';

import '../../../../utils/api_client.dart';
import '../models/user_model.dart';

class AuthDataSource {
  final ApiService _apiService;

  AuthDataSource(this._apiService);

  Future<AuthResponseModel> loginWithEmail({
    required String email,
    required String password,
  }) async
  {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> loginWithPhone({
    required String phoneNumber,
  }) async
  {
    try {
      final response = await _apiService.post(
        '/auth/login-phone',
        data: {
          'phone_number': phoneNumber,
        },
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Phone login failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> verifyOTP({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.verifyEmail,
        data: {
          'email': email,
          'otp': code,
        },
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> resendOTP({
    required String email,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.resendOtp,
        data: {
          'email': email,
        },
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Resend OTP failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> resetPassword({
    required String email,
  }) async
  {
    try {
      final response = await _apiService.post(
        '/auth/reset-password',
        data: {
          'email': email,
        },
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> confirmResetPassword({
    required String token,
    required String newPassword,
  }) async
  {
    try {
      final response = await _apiService.post(
        '/auth/confirm-reset-password',
        data: {
          'token': token,
          'new_password': newPassword,
        },
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Password confirmation failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> register({
    required String email,
    required String mobile,
    required String password,
    required String passwordConfirmation,
    String? fcmToken,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'email': email,
          'mobile': mobile,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'fcm_token': fcmToken,
        },
      );
      return AuthResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }


}
