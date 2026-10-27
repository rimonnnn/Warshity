import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/errors/app_failure.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';

import 'auth_state.dart';

/// State of the very first Firebase auth restore for this app run.
enum AuthSessionStatus {
  /// Firebase has not reported the restored session yet.
  unknown,

  /// A Firebase user is signed in.
  signedIn,

  /// There is no signed-in Firebase user.
  signedOut,
}

/// Central owner of the authentication lifecycle.
///
/// A single instance listens to [AuthRepo.authStateChanges] (the stream that
/// Firebase emits once the persisted session has been restored, or once it
/// knows there is none), so the router and the splash screen can wait for a
/// definitive answer instead of racing the asynchronous web restore.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.registerRepo, this.authRepo) : super(AuthInitial()) {
    _watchSession();
    _watchUserData();
  }

  static const Duration _sessionResolutionTimeout = Duration(seconds: 10);

  final RegisterRepo registerRepo;
  final AuthRepo authRepo;

  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  final Completer<void> _sessionResolved = Completer<void>();
  Future<void>? _sessionReadyFuture;

  AuthSessionStatus _sessionStatus = AuthSessionStatus.unknown;
  bool _hadSignedInUser = false;
  bool _intentionalSignOut = false;

  /// Last known session status. Stays [AuthSessionStatus.unknown] until
  /// Firebase finishes restoring the persisted session.
  AuthSessionStatus get sessionStatus => _sessionStatus;

  /// Completes when the first auth answer arrives (signed in or not).
  ///
  /// Never hangs: falls back to the SDK current user after a timeout so the
  /// splash screen cannot become a dead end.
  Future<void> get sessionReady {
    return _sessionReadyFuture ??= _awaitSessionResolution();
  }

  Future<void> _awaitSessionResolution() async {
    if (_sessionResolved.isCompleted) return;

    try {
      await _sessionResolved.future.timeout(_sessionResolutionTimeout);
    } on TimeoutException {
      _resolveSession(authRepo.currentUser != null);
    }
  }

  void _watchSession() {
    _authSubscription = authRepo.authStateChanges.listen(
      _handleAuthUser,
      onError: (Object error) {
        // A failing listener does not prove the session ended: resolve from
        // whatever the SDK still knows instead of forcing a sign out.
        if (kDebugMode) {
          debugPrint('[auth_session] $error');
        }

        if (!_sessionResolved.isCompleted) {
          _resolveSession(authRepo.currentUser != null);
        }
      },
    );
  }

  void _handleAuthUser(User? user) {
    if (user == null) {
      final sessionLost = _hadSignedInUser && !_intentionalSignOut;

      _hadSignedInUser = false;
      _intentionalSignOut = false;

      // Drop the user document listener so no stale data keeps flowing.
      _userSubscription?.cancel();
      _userSubscription = null;

      _resolveSession(false);

      if (sessionLost && !isClosed) {
        emit(SessionExpired());
      }

      return;
    }

    _hadSignedInUser = true;
    _resolveSession(true);

    // (Re)start the user document listener for the signed-in user only.
    _watchUserData();
  }

  void _resolveSession(bool signedIn) {
    _sessionStatus = signedIn ? AuthSessionStatus.signedIn : AuthSessionStatus.signedOut;

    if (!_sessionResolved.isCompleted) {
      _sessionResolved.complete();
    }
  }

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

      emit(LoginSuccess('login_success'.tr()));
    } on FirebaseAuthException catch (_) {
      emit(AuthError('generic_error_message'.tr()));
    } catch (e) {
      emit(AuthError('generic_error_message'.tr()));
    }
  }

  void _watchUserData() {
    _userSubscription?.cancel();

    _userSubscription = authRepo.watchUserData().listen(
      (user) {
        if (isClosed) return;

        if (user != null) {
          emit(UserLoaded(user));
        }
      },
      onError: (Object error) {
        if (isClosed) return;

        final failure = AppFailure.map(
          error,
          isSignedIn: authRepo.currentUser != null,
        );

        if (failure.isSessionIssue) {
          // The auth listener owns the navigation, just stop reading.
          _userSubscription?.cancel();
          _userSubscription = null;
          return;
        }

        emit(AuthError(failure.message));
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

      emit(PasswordChangedSuccess('password_changed_successfully'.tr()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        emit(AuthError('current_password_incorrect'.tr()));
      } else if (e.code == 'weak-password') {
        emit(AuthError('password_too_weak'.tr()));
      } else {
        emit(AuthError('something_went_wrong'.tr()));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    await _authSubscription?.cancel();

    return super.close();
  }

  Future<void> logOut() async {
    emit(AuthLoading());

    try {
      // Mark the sign out as explicit so the auth listener does not report it
      // as an unexpected session expiry (LogoutSuccess already covers it).
      _intentionalSignOut = true;

      await authRepo.logOut();

      _userSubscription?.cancel();
      _userSubscription = null;
      _hadSignedInUser = false;

      if (!isClosed) {
        emit(LogoutSuccess());
      }
    } catch (e) {
      _intentionalSignOut = false;
      _handleError(e);
    }
  }
}
