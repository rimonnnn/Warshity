
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_state.dart';

import 'products_cubit_test.mocks.dart';

@GenerateMocks([ProductsRepository])
void main() {
  late MockProductsRepository repository;
  late ProductsCubit cubit;

  setUp(() {
    repository = MockProductsRepository();
    cubit = ProductsCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('watchProducts', () {
    test('Should emit loading then success when products are loaded', () async {
      final products = <ProductModel>[];

      when(repository.watchProducts())
          .thenAnswer((_) => Stream.value(products));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductsLoading>(),
          isA<ProductsSuccess>(),
        ]),
      );

      cubit.watchProducts();

      await expectation;

      final state = cubit.state as ProductsSuccess;

      expect(state.products, products);
    });

    test('Should emit loading then error when watching products fails',
        () async {
      when(repository.watchProducts()).thenAnswer(
        (_) => Stream.error(Exception('Failed to load products')),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductsLoading>(),
          isA<ProductsError>(),
        ]),
      );

      cubit.watchProducts();

      await expectation;

      final state = cubit.state as ProductsError;

      expect(
        state.message,
        'Exception: Failed to load products',
      );
    });
  });

  group('increaseQuantity', () {
    test('Should call repository to increase product quantity', () async {
      when(repository.increaseProductQuantity('product-1'))
          .thenAnswer((_) async {});

      await cubit.increaseQuantity('product-1');

      verify(
        repository.increaseProductQuantity('product-1'),
      ).called(1);
    });

    test('Should throw when repository fails', () async {
      when(repository.increaseProductQuantity('product-1'))
          .thenThrow(Exception('Failed'));

      expect(
        () => cubit.increaseQuantity('product-1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('decreaseQuantity', () {
    test('Should call repository to decrease product quantity', () async {
      when(repository.decreaseProductQuantity('product-1'))
          .thenAnswer((_) async {});

      await cubit.decreaseQuantity('product-1');

      verify(
        repository.decreaseProductQuantity('product-1'),
      ).called(1);
    });

    test('Should throw when repository fails', () async {
      when(repository.decreaseProductQuantity('product-1'))
          .thenThrow(Exception('Failed'));

      expect(
        () => cubit.decreaseQuantity('product-1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateQuantity', () {
    test('Should call repository with correct productId and quantity',
        () async {
      when(
        repository.setProductQuantity(
          productId: 'product-1',
          quantity: 10,
        ),
      ).thenAnswer((_) async {});

      await cubit.updateQuantity(
        productId: 'product-1',
        quantity: 10,
      );

      verify(
        repository.setProductQuantity(
          productId: 'product-1',
          quantity: 10,
        ),
      ).called(1);
    });

    test('Should throw when repository fails', () async {
      when(
        repository.setProductQuantity(
          productId: 'product-1',
          quantity: 10,
        ),
      ).thenThrow(Exception('Failed'));

      expect(
        () => cubit.updateQuantity(
          productId: 'product-1',
          quantity: 10,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteProduct', () {
    test('Should call repository to delete product', () async {
      when(repository.deleteProduct('product-1'))
          .thenAnswer((_) async {});

      await cubit.deleteProduct('product-1');

      verify(
        repository.deleteProduct('product-1'),
      ).called(1);
    });

    test('Should rethrow when repository fails', () async {
      when(repository.deleteProduct('product-1'))
          .thenThrow(Exception('Failed to delete product'));

      expect(
        () => cubit.deleteProduct('product-1'),
        throwsA(
          predicate(
            (error) =>
                error.toString() ==
                'Exception: Failed to delete product',
          ),
        ),
      );
    });
  });
}

