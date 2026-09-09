import 'package:warshity/features/auth/register/data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class RegisterSuccess extends AuthState {
  final String message;

  RegisterSuccess(this.message);
}

class LoginSuccess extends AuthState {
  final String message;
  final UserModel? user;

  LoginSuccess(
    this.message, {
    this.user,
  });
}

class UserLoaded extends AuthState {
  final UserModel user;

  UserLoaded(this.user);
}

class EmailVerificationSent extends AuthState {
  final String message;

  EmailVerificationSent(this.message);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
class PasswordChangedSuccess extends AuthState {
  final String message;

  PasswordChangedSuccess(this.message);
}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  ForgotPasswordSuccess(this.message);
}