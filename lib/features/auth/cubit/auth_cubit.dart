import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.registerRepo, this.authRepo) : super(AuthInitial()) {
    _watchUserData();
  }

  final RegisterRepo registerRepo;
  final AuthRepo authRepo;

  StreamSubscription<UserModel?>? _userSubscription;

  Future<void> register({
    required UserModel user,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      await registerRepo.register(user: user, password: password);

      emit(RegisterSuccess("account_created_verify_email".tr()));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> addCategory(String categoryName) async {
    try {
      await registerRepo.addCategory(categoryName);
    } catch (e) {
      log('Add Category Error: $e');

      rethrow;
    }
  }
Stream<List<String>> get categoriesStream {
  return registerRepo.watchCategories();
}
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      await authRepo.login(email: email, password: password);

      _watchUserData();

      emit(LoginSuccess("login_success".tr()));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> signInWithGoogle() async {
    await _signInWithProvider(authRepo.signInWithGoogle, 'Google');
  }

  Future<void> signInWithFacebook() async {
    await _signInWithProvider(authRepo.signInWithFacebook, 'Facebook');
  }

  Future<void> _signInWithProvider(
    Future<UserCredential> Function() signInMethod,
    String providerName,
  ) async {
    emit(AuthLoading());

    try {
      await signInMethod();

      _watchUserData();

      emit(LoginSuccess('login_success'));
    } on FirebaseAuthException catch (e) {
      log(
        '$providerName Sign-In Error: '
        '${e.code} - ${e.message}',
      );

      emit(AuthError('generic_error_message'));
    } catch (e) {
      log('$providerName Sign-In Error: $e');

      emit(AuthError('generic_error_message'));
    }
  }

  void _watchUserData() {
    _userSubscription?.cancel();

    _userSubscription = authRepo.watchUserData().listen(
      (user) {
        if (user != null) {
          emit(UserLoaded(user));
        }
      },
      onError: (error) {
        log('User data error: $error');
      },
    );
  }

  Future<void> resendVerificationEmail() async {
    emit(AuthLoading());

    try {
      await registerRepo.resendEmailVerification();

      emit(EmailVerificationSent("verification_email_sent".tr()));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> checkEmailVerification() async {
    emit(AuthLoading());

    try {
      final verified = await registerRepo.isEmailVerified();

      if (verified) {
        emit(RegisterSuccess("email_verified".tr()));
      } else {
        emit(AuthError("email_not_verified".tr()));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> sendResetLink(String email) async {
    emit(AuthLoading());

    try {
      await authRepo.sendPasswordResetEmail(email);

      emit(ForgotPasswordSuccess("reset_link_sent".tr()));
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object error) {
    if (error is FirebaseAuthException) {
      emit(AuthError(error.message ?? "something_went_wrong".tr()));
    } else {
      emit(AuthError(error.toString()));
    }
  }
Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  emit(AuthLoading());

  try {
    await authRepo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    emit(
      PasswordChangedSuccess(
        'password_changed_successfully'.tr(),
      ),
    );
  } on FirebaseAuthException catch (e) {
    log(
      'Change Password Error: '
      '${e.code} - ${e.message}',
    );

    if (e.code == 'wrong-password' ||
        e.code == 'invalid-credential') {
      emit(
        AuthError(
          'current_password_incorrect'.tr(),
        ),
      );
    } else if (e.code == 'weak-password') {
      emit(
        AuthError(
          'password_too_weak'.tr(),
        ),
      );
    } else {
      emit(
        AuthError(
          'something_went_wrong'.tr(),
        ),
      );
    }
  } catch (e) {
    log(
      'Change Password Error: $e',
    );

    emit(
      AuthError(
        e.toString(),
      ),
    );
  }
}
  @override
  Future<void> close() async {
    await _userSubscription?.cancel();

    return super.close();
  }
}
