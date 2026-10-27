import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';

import 'auth_mocks.mocks.dart';

/// Minimal signed-in Firebase user: AuthCubit only null-checks it.
class _SignedInUser extends Mock implements User {}

void main() {
  late MockAuthRepo authRepo;
  late MockRegisterRepo registerRepo;
  late StreamController<User?> authController;
  late StreamController<UserModel?> userDocController;

  AuthCubit buildCubit() {
    return AuthCubit(registerRepo, authRepo);
  }

  setUp(() {
    authRepo = MockAuthRepo();
    registerRepo = MockRegisterRepo();

    authController = StreamController<User?>.broadcast();
    userDocController = StreamController<UserModel?>.broadcast();

    when(authRepo.authStateChanges).thenAnswer((_) => authController.stream);
    when(authRepo.watchUserData()).thenAnswer((_) => userDocController.stream);
    when(authRepo.currentUser).thenReturn(null);
  });

  tearDown(() async {
    await authController.close();
    await userDocController.close();
  });

  Future<void> pumpEventQueue() => Future<void>.delayed(Duration.zero);

  group('session resolution', () {
    test('stays unknown until Firebase answers the first auth event',
        () async {
      final cubit = buildCubit();

      expect(cubit.sessionStatus, AuthSessionStatus.unknown);

      var ready = false;
      // ignore: unawaited_futures
      cubit.sessionReady.then((_) => ready = true);

      await pumpEventQueue();

      expect(ready, isFalse);
      expect(cubit.sessionStatus, AuthSessionStatus.unknown);

      await cubit.close();
    });

    test('a restored user resolves the session and completes sessionReady',
        () async {
      final cubit = buildCubit();

      final ready = cubit.sessionReady.then((_) => true);

      authController.add(_SignedInUser());
      await pumpEventQueue();

      expect(cubit.sessionStatus, AuthSessionStatus.signedIn);
      expect(await ready, isTrue);

      await cubit.close();
    });

    test(
      'a failing auth stream falls back to the SDK user instead of hanging',
      () async {
        final cubit = buildCubit();

        final ready = cubit.sessionReady.then((_) => true);

        authController.addError(
          FirebaseException(plugin: 'firebase_auth', code: 'network-request-failed'),
        );
        await pumpEventQueue();

        // No SDK user in this test: signed out, but never "unknown".
        expect(cubit.sessionStatus, AuthSessionStatus.signedOut);
        expect(await ready, isTrue);

        await cubit.close();
      },
    );
  });

  group('signed-in -> signed-out transition', () {
    test('emits SessionExpired when the session disappears on its own',
        () async {
      final cubit = buildCubit();

      authController.add(_SignedInUser());
      await pumpEventQueue();

      expect(cubit.sessionStatus, AuthSessionStatus.signedIn);

      authController.add(null);
      await pumpEventQueue();

      expect(cubit.state, isA<SessionExpired>());
      expect(cubit.sessionStatus, AuthSessionStatus.signedOut);

      await cubit.close();
    });

    test('the very first signed-out answer is not reported as an expiry',
        () async {
      final cubit = buildCubit();

      authController.add(null);
      await pumpEventQueue();

      expect(cubit.state, isNot(isA<SessionExpired>()));
      expect(cubit.sessionStatus, AuthSessionStatus.signedOut);

      await cubit.close();
    });

    test('an explicit sign out is not reported as an unexpected expiry',
        () async {
      when(authRepo.logOut()).thenAnswer((_) async {});

      final cubit = buildCubit();

      authController.add(_SignedInUser());
      await pumpEventQueue();

      await cubit.logOut();
      await pumpEventQueue();

      expect(cubit.state, isA<LogoutSuccess>());

      // Firebase confirms the sign out afterwards.
      authController.add(null);
      await pumpEventQueue();

      expect(cubit.state, isA<LogoutSuccess>());
      expect(cubit.state, isNot(isA<SessionExpired>()));

      await cubit.close();
    });
  });

  group('user document errors', () {
    test('permission-denied is mapped to a friendly message', () async {
      // A permission problem only makes sense for a signed-in user.
      when(authRepo.currentUser).thenReturn(_SignedInUser());

      final cubit = buildCubit();

      userDocController.addError(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        ),
      );
      await pumpEventQueue();

      expect(cubit.state, isA<AuthError>());

      final message = (cubit.state as AuthError).message;

      expect(message, isNot(contains('permission-denied')));
      expect(message, isNot(contains('Missing or insufficient')));
      expect(message, isNot(contains('FirebaseException')));

      await cubit.close();
    });

    test('a session problem only stops the listener, it emits no error state',
        () async {
      when(authRepo.currentUser).thenReturn(null);

      final cubit = buildCubit();

      userDocController.addError(
        FirebaseException(plugin: 'cloud_firestore', code: 'unauthenticated'),
      );
      await pumpEventQueue();

      expect(cubit.state, isNot(isA<AuthError>()));

      await cubit.close();
    });
  });
}
