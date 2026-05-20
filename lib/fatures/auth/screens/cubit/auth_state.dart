// ============================================
// FILE: lib/fatures/auth/screens/cubit/auth_state.dart
// ============================================

import 'package:albayan/fatures/auth/data/models/country_model.dart';
import 'package:albayan/fatures/auth/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// ── Initial ───────────────────────────────────────────────────
class AuthInitial extends AuthState {
  const AuthInitial();
}

// ── Countries ─────────────────────────────────────────────────
class CountriesLoading extends AuthState {
  const CountriesLoading();
}

class CountriesLoaded extends AuthState {
  final List<CountryModel> countries;
  const CountriesLoaded(this.countries);

  @override
  List<Object?> get props => [countries];
}

class CountriesError extends AuthState {
  final String message;
  const CountriesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Login ─────────────────────────────────────────────────────
class LoginLoading extends AuthState {
  const LoginLoading();
}

class LoginSuccess extends AuthState {
  final UserModel user;
  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginError extends AuthState {
  final String message;
  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Mobile login: server sent OTP, navigate to OTP screen
class LoginOtpRequired extends AuthState {
  final String mobileNumber; // full number with country code, e.g. +96279...
  const LoginOtpRequired(this.mobileNumber);

  @override
  List<Object?> get props => [mobileNumber];
}

// ── Register ──────────────────────────────────────────────────
class RegisterLoading extends AuthState {
  const RegisterLoading();
}

class RegisterSuccess extends AuthState {
  final String recipient;
  final bool isEmail;
  const RegisterSuccess({required this.recipient, required this.isEmail});

  @override
  List<Object?> get props => [recipient, isEmail];
}

class RegisterError extends AuthState {
  final String message;
  const RegisterError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Verify OTP ────────────────────────────────────────────────
class OtpLoading extends AuthState {
  const OtpLoading();
}

class OtpVerified extends AuthState {
  final UserModel user;
  const OtpVerified(this.user);

  @override
  List<Object?> get props => [user];
}

class OtpError extends AuthState {
  final String message;
  const OtpError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Resend OTP ────────────────────────────────────────────────
class OtpResendLoading extends AuthState {
  const OtpResendLoading();
}

class OtpResendSuccess extends AuthState {
  const OtpResendSuccess();
}

class OtpResendError extends AuthState {
  final String message;
  const OtpResendError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Profile ───────────────────────────────────────────────────
class ProfileLoading extends AuthState {
  const ProfileLoading();
}

class ProfileLoaded extends AuthState {
  final UserModel user;
  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends AuthState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Logout ────────────────────────────────────────────────────
class LogoutLoading extends AuthState {
  const LogoutLoading();
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

class LogoutError extends AuthState {
  final String message;
  const LogoutError(this.message);

  @override
  List<Object?> get props => [message];
}
