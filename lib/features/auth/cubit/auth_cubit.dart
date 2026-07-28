import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterRepo registerRepo;
  final AuthRepo authRepo;

  AuthCubit(this.registerRepo, this.authRepo) : super(AuthInitial());

  Future<void> register({
    required UserModel user,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      await registerRepo.register(
        user: user,
        password: password,
      );

      emit(
        RegisterSuccess(
          "Account_created".tr(),
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkEmailVerification() async {
    emit(AuthLoading());

    try {
      final verified = await registerRepo.isEmailVerified();

      if (verified) {
        emit(RegisterSuccess("verify".tr()));
      } else {
        emit(AuthError("notverified".tr()));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await registerRepo.resendEmailVerification();

      emit(
        EmailVerificationSent(
          "verify_email".tr(),
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      await authRepo.login(
        email: email,
        password: password,
      );

      emit(LoginSuccess("login_success".tr()));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "wrong".tr()));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      await authRepo.signInWithGoogle();

      emit(LoginSuccess("login_success".tr()));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "Google Sign-In failed"));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
    emit(AuthLoading());

    try {
      await authRepo.signInWithFacebook();

      emit(LoginSuccess("login_success".tr()));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "Facebook Sign-In failed"));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendResetLink(String email) async {
    emit(AuthLoading());

    try {
      await authRepo.sendPasswordResetEmail(email);

      emit(
        ForgotPasswordSuccess(
          "Reset link sent to your email",
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}