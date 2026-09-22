import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';

import 'auth_mocks.mocks.dart';

void main() {
  late MockAuthRepo mockAuthRepo;
  late MockRegisterRepo mockRegisterRepo;
  late MockUserCredential mockUserCredential;
  late AuthCubit authCubit;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    mockRegisterRepo = MockRegisterRepo();
    mockUserCredential = MockUserCredential();

    when(
      mockAuthRepo.watchUserData(),
    ).thenAnswer((_) => const Stream<UserModel?>.empty());

    authCubit = AuthCubit(mockRegisterRepo, mockAuthRepo);
  });

  tearDown(() async {
    await authCubit.close();
  });

  group('login', () {
    test(
      'should emit [AuthLoading, LoginSuccess] when login succeeds',
      () async {
        when(
          mockAuthRepo.login(
            email: 'test@gmail.com',
            password: '12345678',
          ),
        ).thenAnswer((_) async => mockUserCredential);

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<LoginSuccess>(),
          ]),
        );

        await authCubit.login(
          email: 'test@gmail.com',
          password: '12345678',
        );

        await stateExpectation;

        verify(
          mockAuthRepo.login(
            email: 'test@gmail.com',
            password: '12345678',
          ),
        ).called(1);

        verify(mockAuthRepo.watchUserData()).called(2);
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when login fails',
      () async {
        when(
          mockAuthRepo.login(
            email: 'test@gmail.com',
            password: '12345678',
          ),
        ).thenThrow(Exception('Login failed'));

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<AuthError>(),
          ]),
        );

        await authCubit.login(
          email: 'test@gmail.com',
          password: '12345678',
        );

        await stateExpectation;

        verify(
          mockAuthRepo.login(
            email: 'test@gmail.com',
            password: '12345678',
          ),
        ).called(1);
      },
    );
  });

  group('signInWithGoogle', () {
    test(
      'should emit [AuthLoading, AuthError] when Google sign in fails',
      () async {
        when(
          mockAuthRepo.signInWithGoogle(),
        ).thenThrow(Exception('Google login failed'));

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<AuthError>(),
          ]),
        );

        await authCubit.signInWithGoogle();

        await stateExpectation;

        verify(
          mockAuthRepo.signInWithGoogle(),
        ).called(1);
      },
    );
  });

  group('signInWithFacebook', () {
    test(
      'should emit [AuthLoading, AuthError] when Facebook sign in fails',
      () async {
        when(
          mockAuthRepo.signInWithFacebook(),
        ).thenThrow(Exception('Facebook login failed'));

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<AuthError>(),
          ]),
        );

        await authCubit.signInWithFacebook();

        await stateExpectation;

        verify(
          mockAuthRepo.signInWithFacebook(),
        ).called(1);
      },
    );
  });
}
