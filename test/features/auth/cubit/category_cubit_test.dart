import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:warshity/features/auth/cubit/auth_cubit.dart';
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

  group('addCategory', () {
    test('should call registerRepo.addCategory', () async {
      when(
        mockRegisterRepo.addCategory('Food'),
      ).thenAnswer((_) async {});

      await authCubit.addCategory('Food');

      verify(
        mockRegisterRepo.addCategory('Food'),
      ).called(1);
    });

    test('should rethrow error when addCategory fails', () async {
      when(
        mockRegisterRepo.addCategory('Food'),
      ).thenThrow(Exception('Failed'));

      expect(
        () => authCubit.addCategory('Food'),
        throwsException,
      );
    });
  });

  group('categoriesStream', () {
    test('should return registerRepo.watchCategories stream', () {
      final categories = [
        'Food',
        'Drinks',
        'Electronics',
      ];

      when(
        mockRegisterRepo.watchCategories(),
      ).thenAnswer((_) => Stream.value(categories));

      expect(
        authCubit.categoriesStream,
        emits(categories),
      );

      verify(
        mockRegisterRepo.watchCategories(),
      ).called(1);
    });
  });
}
