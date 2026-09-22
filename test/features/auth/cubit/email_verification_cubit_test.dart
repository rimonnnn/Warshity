import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';

import 'auth_mocks.mocks.dart';

void main() {
  late MockAuthRepo mockAuthRepo;
  late MockRegisterRepo mockRegisterRepo;
  late AuthCubit authCubit;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    mockRegisterRepo = MockRegisterRepo();

    when(
      mockAuthRepo.watchUserData(),
    ).thenAnswer((_) => const Stream<UserModel?>.empty());

    authCubit = AuthCubit(mockRegisterRepo, mockAuthRepo);
  });

  tearDown(() async {
    await authCubit.close();
  });

  group('resendVerificationEmail', () {
    test(
      'should emit [AuthLoading, EmailVerificationSent] when succeeds',
      () async {
        when(
          mockRegisterRepo.resendEmailVerification(),
        ).thenAnswer((_) async {});

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<EmailVerificationSent>(),
          ]),
        );

        await authCubit.resendVerificationEmail();

        await stateExpectation;

        verify(
          mockRegisterRepo.resendEmailVerification(),
        ).called(1);
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when resend fails',
      () async {
        when(
          mockRegisterRepo.resendEmailVerification(),
        ).thenThrow(Exception('Failed'));

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<AuthError>(),
          ]),
        );

        await authCubit.resendVerificationEmail();

        await stateExpectation;
      },
    );
  });

  group('checkEmailVerification', () {
    test(
      'should emit [AuthLoading, RegisterSuccess] when email is verified',
      () async {
        when(
          mockRegisterRepo.isEmailVerified(),
        ).thenAnswer((_) async => true);

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<RegisterSuccess>(),
          ]),
        );

        await authCubit.checkEmailVerification();

        await stateExpectation;

        verify(
          mockRegisterRepo.isEmailVerified(),
        ).called(1);
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when email is not verified',
      () async {
        when(
          mockRegisterRepo.isEmailVerified(),
        ).thenAnswer((_) async => false);

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<AuthError>(),
          ]),
        );

        await authCubit.checkEmailVerification();

        await stateExpectation;

        verify(
          mockRegisterRepo.isEmailVerified(),
        ).called(1);
      },
    );
  });
}
