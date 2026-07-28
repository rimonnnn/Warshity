abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class RegisterSuccess extends AuthState {
  final String message;

  RegisterSuccess(this.message);
}

class LoginSuccess extends AuthState {
  final String message;

  LoginSuccess(this.message);
}

class EmailVerificationSent extends AuthState {
  final String message;

  EmailVerificationSent(this.message);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  ForgotPasswordSuccess(this.message);
}
