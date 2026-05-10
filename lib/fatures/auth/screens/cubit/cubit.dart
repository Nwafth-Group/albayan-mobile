import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/shared_pref_helper.dart';
import '../../data/datasource/auth_datasource.dart';
import '../../data/models/user_model.dart';

import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  final String? message;

  const AuthSuccess({required this.user, this.message});

  @override
  List<Object?> get props => [user, message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class OTPSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const OTPSent({required this.verificationId, required this.phoneNumber});

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

class OTPResent extends AuthState {
  final String message;

  const OTPResent(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent(this.email);

  @override
  List<Object> get props => [email];
}

class PasswordResetSuccess extends AuthState {}


class AuthCubit extends Cubit<AuthState> {
  final AuthDataSource _authDataSource;

  AuthCubit(this._authDataSource) : super(AuthInitial());

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async
  {
    emit(AuthLoading());
    try {
      final response = await _authDataSource.loginWithEmail(
        email: email,
        password: password,
      );
      if (response.user != null) {
        if (response.token != null) {
          await SharedPrefHelper.saveToken(response.token!);
        }
        await SharedPrefHelper.saveUser(response.user!);
        emit(AuthSuccess(user: response.user!, message: response.message));
      } else {
        emit(AuthError(response.message ?? 'Login failed'));
      }
    } catch (e) {
      print("error in login $e");
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loginWithPhone({required String phoneNumber}) async {
    emit(AuthLoading());
    try {
      final response = await _authDataSource.loginWithPhone(
        phoneNumber: phoneNumber,
      );

      if (response.success && response.verificationId != null) {
        emit(OTPSent(
          verificationId: response.verificationId!,
          phoneNumber: phoneNumber,
        ));
      } else {
        emit(AuthError(response.message ?? 'Failed to send OTP'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> verifyOTP({
    required String email,
    required String code,
  }) async
  {
    emit(AuthLoading());
    try {
      final response = await _authDataSource.verifyOTP(
        email: email,
        code: code,
      );
      print(response);

      if (response.user != null) {
        // Save token if provided
        if (response.token != null) {
          await SharedPrefHelper.saveToken(response.token!);
        }
        // Save user data
        await SharedPrefHelper.saveUser(response.user!);
        emit(AuthSuccess(user: response.user!, message: response.message));
      } else {
        emit(AuthError(response.message ?? 'OTP verification failed'));
      }
    } catch (e) {
      print("error in verify OTP $e");
      emit(AuthError(e.toString().replaceAll('Exception: ', '').replaceAll('OTP verification failed: ', '')));
    }
  }

  Future<void> resendOTP({required String email}) async {
    emit(AuthLoading());
    try {
      final response = await _authDataSource.resendOTP(
        email: email,
      );

      if (response.success) {
        emit(OTPResent(response.message ?? 'OTP has been resent successfully'));
      } else {
        emit(AuthError(response.message ?? 'Failed to resend OTP'));
      }
    } catch (e) {
      print("error in resend OTP $e");
      emit(AuthError(e.toString().replaceAll('Exception: ', '').replaceAll('Resend OTP failed: ', '')));
    }
  }

  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());
    try {
      final response = await _authDataSource.resetPassword(email: email);

      if (response.success) {
        emit(PasswordResetSent(email));
      } else {
        emit(AuthError(response.message ?? 'Failed to send reset email'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> confirmResetPassword({
    required String token,
    required String newPassword,
  }) async
  {
    emit(AuthLoading());
    try {
      final response = await _authDataSource.confirmResetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.success) {
        emit(PasswordResetSuccess());
      } else {
        emit(AuthError(response.message ?? 'Failed to reset password'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await SharedPrefHelper.logout();
    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await SharedPrefHelper.isLoggedIn();

      if (isLoggedIn) {
        final user = await SharedPrefHelper.getUser();
        final token = await SharedPrefHelper.getToken();
        print("rrrrrr $token");
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthError('UnAuth'));
        }
      } else {
        emit(AuthError('UnAuth'));
      }
    } catch(e){
      print("error in checking $e");
      emit(AuthError('UnAuth'));
    }
  }
}