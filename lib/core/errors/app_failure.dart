import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Thrown by the data layer when an operation needs a signed-in Firebase user
/// but none exists (session lost, reload before auth restore, sign out).
class UnauthenticatedException implements Exception {
  const UnauthenticatedException();

  @override
  String toString() => 'user_not_authenticated'.tr();
}

/// Category of a failure, used to pick the right UI reaction.
enum AppErrorKind {
  /// There is no signed-in user: stop loading data and send the user to login.
  unauthenticated,

  /// Signed-in user without permission for that resource.
  permissionDenied,

  /// Connectivity problem, retrying can help.
  network,

  /// Backend problem, retrying can help.
  server,

  /// Anything else (business rules or real programming errors).
  unknown,
}

/// User facing description of a failure. Never contains tokens or stack traces.
@immutable
class AppFailure {
  const AppFailure({
    required this.kind,
    required this.message,
    this.canRetry = false,
  });

  final AppErrorKind kind;
  final String message;
  final bool canRetry;

  /// True when the failure means "there is no authenticated user".
  bool get isSessionIssue => kind == AppErrorKind.unauthenticated;

  /// Maps any error thrown by Firestore/Auth/data sources to a safe message.
  ///
  /// * [permission-denied]/[unauthenticated] become friendly messages, never
  ///   the raw Firebase text shown to the user.
  /// * A permission problem raised while [isSignedIn] is `false` is treated as
  ///   a session problem, not as an access problem.
  /// * Plain [Exception]s raised on purpose by business code keep their own
  ///   (already localized) message, and unexpected Dart errors are replaced by
  ///   a generic message so programming errors are not disguised as
  ///   permission errors nor leaked to the screen.
  static AppFailure map(Object error, {bool? isSignedIn}) {
    final kind = _kindOf(error);

    if (kDebugMode) {
      debugPrint('[$kind] $error');
    }

    return _build(kind, error, isSignedIn);
  }

  static AppErrorKind _kindOf(Object error) {
    if (error is UnauthenticatedException) {
      return AppErrorKind.unauthenticated;
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'unauthenticated':
          return AppErrorKind.unauthenticated;

        case 'permission-denied':
          return AppErrorKind.permissionDenied;

        case 'unavailable':
        case 'deadline-exceeded':
        case 'network-request-failed':
          return AppErrorKind.network;

        case 'internal':
        case 'resource-exhausted':
        case 'unknown':
          return AppErrorKind.server;

        default:
          // Business level codes (not-found, invalid-argument, ...) keep the
          // behaviour the app already has: their own message is shown.
          return AppErrorKind.unknown;
      }
    }

    if (error is TimeoutException) {
      return AppErrorKind.network;
    }

    if (_isTechnicalError(error)) {
      return AppErrorKind.server;
    }

    return AppErrorKind.unknown;
  }

  static AppFailure _build(
    AppErrorKind kind,
    Object error,
    bool? isSignedIn,
  ) {
    switch (kind) {
      case AppErrorKind.unauthenticated:
        return AppFailure(
          kind: kind,
          message: 'session_expired'.tr(),
        );

      case AppErrorKind.permissionDenied:
        // Signed out: this is a session problem, not an access problem.
        if (isSignedIn == false) {
          return AppFailure(
            kind: AppErrorKind.unauthenticated,
            message: 'session_expired'.tr(),
          );
        }
        return AppFailure(
          kind: kind,
          message: 'no_access_permission'.tr(),
        );

      case AppErrorKind.network:
        return AppFailure(
          kind: kind,
          message: 'connection_error'.tr(),
          canRetry: true,
        );

      case AppErrorKind.server:
        return AppFailure(
          kind: kind,
          message: 'generic_error_message'.tr(),
          canRetry: true,
        );

      case AppErrorKind.unknown:
        return AppFailure(kind: kind, message: error.toString());
    }
  }

  /// Unexpected framework/Dart errors are technical: show a generic message
  /// instead of the raw text, while the original is still logged in debug.
  static bool _isTechnicalError(Object error) {
    return error is TypeError ||
        error is NoSuchMethodError ||
        error is AssertionError ||
        error is RangeError ||
        error is FormatException ||
        error is StateError ||
        error is UnimplementedError;
  }
}
