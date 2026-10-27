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

  test('initial state should be AuthInitial', () {
    expect(authCubit.state, isA<AuthInitial>());
  });

  group('register', () {
    final user = UserModel(
      uid: '123',
      email: 'test@gmail.com',
      ownerName: 'Kirolos',
      shopName: 'My Shop',
      activity: 'Trade',
    );

    test(
      'should emit [AuthLoading, RegisterSuccess] when register succeeds',
      () async {
        when(
          mockRegisterRepo.register(
            user: user,
            password: '12345678',
          ),
        ).thenAnswer((_) async {});

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<RegisterSuccess>(),
          ]),
        );

        await authCubit.register(
          user: user,
          password: '12345678',
        );

        await stateExpectation;

        verify(
          mockRegisterRepo.register(
            user: user,
            password: '12345678',
          ),
        ).called(1);
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when register fails',
      () async {
        when(
          mockRegisterRepo.register(
            user: user,
            password: '12345678',
          ),
        ).thenThrow(Exception('Register failed'));

        final stateExpectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            isA<AuthLoading>(),
            isA<AuthError>(),
          ]),
        );

        await authCubit.register(
          user: user,
          password: '12345678',
        );

        await stateExpectation;

        verify(
          mockRegisterRepo.register(
            user: user,
            password: '12345678',
          ),
        ).called(1);
      },
    );
  });
}
