
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/products/data/models/category_model.dart';
import 'package:warshity/features/products/data/repo/categories_repository.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';

import 'categories_cubit_test.mocks.dart';

@GenerateMocks([CategoriesRepository])
void main() {
  late MockCategoriesRepository repository;
  late CategoriesCubit cubit;

  setUp(() {
    repository = MockCategoriesRepository();
    cubit = CategoriesCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  final categories = [
    CategoryModel(
      id: '1',
      name: 'Furniture',
    ),
    CategoryModel(
      id: '2',
      name: 'Wood',
    ),
  ];

  group('watchCategories', () {
    test('Should emit loading then loaded', () async {
      when(repository.watchCategories())
          .thenAnswer((_) => Stream.value(categories));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CategoriesLoading>(),
          isA<CategoriesLoaded>(),
        ]),
      );

      cubit.watchCategories();

      await expectation;

      final state = cubit.state as CategoriesLoaded;

      expect(state.categories, categories);
    });

    test('Should emit loading then error when stream fails', () async {
      when(repository.watchCategories()).thenAnswer(
        (_) => Stream.error(
          Exception('Failed to load categories'),
        ),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CategoriesLoading>(),
          isA<CategoriesError>(),
        ]),
      );

      cubit.watchCategories();

      await expectation;

      final state = cubit.state as CategoriesError;

      expect(
        state.message,
        'Exception: Failed to load categories',
      );
    });
  });

  group('addCategory', () {
    test('Should do nothing when category name is empty', () async {
      await cubit.addCategory('   ');

      expect(cubit.state, isA<CategoriesInitial>());

      verifyNever(repository.addCategory(any));
    });

    test('Should trim category name before adding', () async {
      when(repository.addCategory('Furniture'))
          .thenAnswer((_) async {});

      await cubit.addCategory('  Furniture  ');

      verify(
        repository.addCategory('Furniture'),
      ).called(1);
    });

    test('Should emit AddCategoryLoading before adding category', () async {
      when(repository.addCategory('Furniture'))
          .thenAnswer((_) async {});

      final expectation = expectLater(
        cubit.stream,
        emits(
          isA<AddCategoryLoading>(),
        ),
      );

      await cubit.addCategory('Furniture');

      await expectation;
    });

    test('Should not emit success state after adding category', () async {
      when(repository.addCategory('Furniture'))
          .thenAnswer((_) async {});

      await cubit.addCategory('Furniture');

      expect(
        cubit.state,
        isA<AddCategoryLoading>(),
      );
    });

    test('Should emit AddCategoryError when adding category fails',
        () async {
      when(repository.addCategory('Furniture'))
          .thenThrow(
        Exception('Failed to add category'),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<AddCategoryLoading>(),
          isA<AddCategoryError>(),
        ]),
      );

      await cubit.addCategory('Furniture');

      await expectation;

      final state = cubit.state as AddCategoryError;

      expect(
        state.message,
        'Exception: Failed to add category',
      );
    });

    test('Should preserve current categories when adding fails',
        () async {
      when(repository.watchCategories())
          .thenAnswer((_) => Stream.value(categories));

      cubit.watchCategories();

      await Future<void>.delayed(Duration.zero);

      when(repository.addCategory('Tools'))
          .thenThrow(
        Exception('Failed to add category'),
      );

      await cubit.addCategory('Tools');

      final state = cubit.state as AddCategoryError;

      expect(
        state.categories,
        categories,
      );
    });
  });
}

