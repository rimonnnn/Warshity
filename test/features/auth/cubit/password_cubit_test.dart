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

  group('sendResetLink', () {
    test(
      'should emit [AuthLoading, ForgotPasswordSuccess] when succeeds',
      () async {
        when(
          mockAuthRepo.sendPasswordResetEmail('test@gmail.com'),
        ).thenAnswer((_) async {});

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<ForgotPasswordSuccess>(),
          ]),
        );

        await authCubit.sendResetLink('test@gmail.com');

        await stateExpectation;

        verify(
          mockAuthRepo.sendPasswordResetEmail('test@gmail.com'),
        ).called(1);
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when reset fails',
      () async {
        when(
          mockAuthRepo.sendPasswordResetEmail('test@gmail.com'),
        ).thenThrow(Exception('Reset failed'));

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<AuthError>(),
          ]),
        );

        await authCubit.sendResetLink('test@gmail.com');

        await stateExpectation;
      },
    );
  });

  group('changePassword', () {
    test(
      'should emit [AuthLoading, PasswordChangedSuccess] when succeeds',
      () async {
        when(
          mockAuthRepo.changePassword(
            currentPassword: 'oldPassword',
            newPassword: 'newPassword',
          ),
        ).thenAnswer((_) async {});

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<PasswordChangedSuccess>(),
          ]),
        );

        await authCubit.changePassword(
          currentPassword: 'oldPassword',
          newPassword: 'newPassword',
        );

        await stateExpectation;

        verify(
          mockAuthRepo.changePassword(
            currentPassword: 'oldPassword',
            newPassword: 'newPassword',
          ),
        ).called(1);
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when change password fails',
      () async {
        when(
          mockAuthRepo.changePassword(
            currentPassword: 'oldPassword',
            newPassword: 'newPassword',
          ),
        ).thenThrow(Exception('Something went wrong'));

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<AuthError>(),
          ]),
        );

        await authCubit.changePassword(
          currentPassword: 'oldPassword',
          newPassword: 'newPassword',
        );

        await stateExpectation;
      },
    );
  });
}
