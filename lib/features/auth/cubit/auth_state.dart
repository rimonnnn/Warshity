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

class LogoutSuccess extends AuthState {}

/// The signed-in user disappeared without an explicit sign out
/// (expired/revoked session, cleared site data, token refresh failure).
///
/// Listeners must stop user-scoped listeners and send the user to login.
class SessionExpired extends AuthState {}