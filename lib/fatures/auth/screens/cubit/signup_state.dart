
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final String verificationId;
  final String phoneNumber;
  final UserModel? user;

  const SignupSuccess({
    required this.verificationId,
    required this.phoneNumber,
    this.user,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber, user];
}

class SignupSuccessWithoutOTP extends SignupState {
  final UserModel? user;
  final String? token;

  const SignupSuccessWithoutOTP({
    this.user,
    this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

class SignupError extends SignupState {
  final String message;

  const SignupError(this.message);

  @override
  List<Object?> get props => [message];
}

class SignupPasswordVisibilityChanged extends SignupState {
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const SignupPasswordVisibilityChanged({
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
  });

  @override
  List<Object?> get props => [isPasswordVisible, isConfirmPasswordVisible];
}