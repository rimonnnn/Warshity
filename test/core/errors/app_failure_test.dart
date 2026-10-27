import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/errors/app_failure.dart';

FirebaseException _firestoreError(String code, [String? message]) {
  return FirebaseException(
    plugin: 'cloud_firestore',
    code: code,
    message: message,
  );
}

void main() {
  group('AppFailure.map - session problems', () {
    test('unauthenticated code is reported as a session issue', () {
      final failure = AppFailure.map(_firestoreError('unauthenticated'));

      expect(failure.kind, AppErrorKind.unauthenticated);
      expect(failure.isSessionIssue, isTrue);
      expect(failure.message, isNotEmpty);
    });

    test('UnauthenticatedException is reported as a session issue', () {
      final failure = AppFailure.map(const UnauthenticatedException());

      expect(failure.isSessionIssue, isTrue);
      expect(failure.message, isNotEmpty);
    });

    test(
      'permission-denied while signed out is a session problem, not access',
      () {
        final failure = AppFailure.map(
          _firestoreError('permission-denied'),
          isSignedIn: false,
        );

        expect(failure.kind, AppErrorKind.unauthenticated);
        expect(failure.isSessionIssue, isTrue);
      },
    );
  });

  group('AppFailure.map - permission problems', () {
    test('permission-denied for a signed-in user never leaks Firebase text', () {
      final failure = AppFailure.map(
        _firestoreError(
          'permission-denied',
          'Missing or insufficient permissions.',
        ),
      );

      expect(failure.kind, AppErrorKind.permissionDenied);
      expect(failure.isSessionIssue, isFalse);
      expect(failure.message, isNot(contains('permission-denied')));
      expect(failure.message, isNot(contains('Missing or insufficient')));
      expect(failure.message, isNot(contains('FirebaseException')));
    });
  });

  group('AppFailure.map - retryable problems', () {
    for (final code in [
      'unavailable',
      'deadline-exceeded',
      'network-request-failed',
    ]) {
      test('$code is retryable and hides the raw code', () {
        final failure = AppFailure.map(_firestoreError(code));

        expect(failure.kind, AppErrorKind.network);
        expect(failure.canRetry, isTrue);
        expect(failure.message, isNot(contains(code)));
      });
    }

    test('TimeoutException is treated as a connectivity problem', () {
      final failure = AppFailure.map(
        TimeoutException('watchClients', const Duration(seconds: 5)),
      );

      expect(failure.kind, AppErrorKind.network);
      expect(failure.canRetry, isTrue);
    });

    test('technical Dart errors are hidden behind a generic retryable message',
        () {
      final failure = AppFailure.map(
        TypeError(),
      );

      expect(failure.kind, AppErrorKind.server);
      expect(failure.canRetry, isTrue);
      expect(failure.message, isNot(contains('TypeError')));
    });
  });

  group('AppFailure.map - business messages are preserved', () {
    test('a plain Exception keeps its own (already localized) text', () {
      final failure = AppFailure.map(Exception('debt_payment_exceeds_balance'));

      expect(failure.kind, AppErrorKind.unknown);
      expect(failure.canRetry, isFalse);
      expect(failure.message, 'Exception: debt_payment_exceeds_balance');
    });

    test('business Firestore codes stay in the unknown bucket (no retry)',
        () {
      final failure = AppFailure.map(_firestoreError('not-found'));

      expect(failure.kind, AppErrorKind.unknown);
      expect(failure.canRetry, isFalse);
      expect(failure.isSessionIssue, isFalse);
    });
  });
}
