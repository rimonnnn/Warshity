import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_state.dart';

import 'products_cubit_test.mocks.dart';

@GenerateMocks([ProductsRepository])
void main() {
  late MockProductsRepository repository;
  late AddProductCubit cubit;

  setUp(() {
    repository = MockProductsRepository();
    cubit = AddProductCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  final product = ProductModel(
    id: 'product-1',
    name: 'Product 1',
    barcode: '12345',
    category: 'Category 1',
    price: 100.0,
    quantity: 10,
    unit: 'piece',
    imageUrl: 'old-image-url',
  );

  group('addProduct', () {
    test(
      'Should add product with default image when no image is provided',
      () async {
        when(repository.addProduct(any)).thenAnswer((_) async {});

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([isA<AddProductLoading>(), isA<AddProductSuccess>()]),
        );

        await cubit.addProduct(product: product);

        await expectation;

        final captured =
            verify(repository.addProduct(captureAny)).captured.single
                as ProductModel;

        expect(captured.imageUrl, AddProductCubit.defaultProductImage);

        expect(captured.id, product.id);
        expect(captured.name, product.name);
        expect(captured.price, product.price);
        expect(captured.quantity, product.quantity);
      },
    );

    test('Should upload image and use uploaded URL', () async {
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      when(
        repository.uploadProductImage(imageBytes, 'product_image.png'),
      ).thenAnswer((_) async => 'https://example.com/product.png');

      when(repository.addProduct(any)).thenAnswer((_) async {});

      await cubit.addProduct(
        product: product,
        imageBytes: imageBytes,
        imageName: 'product_image.png',
      );

      expect(cubit.state, isA<AddProductSuccess>());

      verify(
        repository.uploadProductImage(imageBytes, 'product_image.png'),
      ).called(1);

      final captured =
          verify(repository.addProduct(captureAny)).captured.single
              as ProductModel;

      expect(captured.imageUrl, 'https://example.com/product.png');
    });

    test('Should not upload image when imageBytes is empty', () async {
      final imageBytes = Uint8List(0);

      when(repository.addProduct(any)).thenAnswer((_) async {});

      await cubit.addProduct(product: product, imageBytes: imageBytes);

      verifyNever(repository.uploadProductImage(any, any));

      final captured =
          verify(repository.addProduct(captureAny)).captured.single
              as ProductModel;

      expect(captured.imageUrl, AddProductCubit.defaultProductImage);
    });

    test('Should emit error when image upload fails', () async {
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      when(
        repository.uploadProductImage(imageBytes, 'product_image.png'),
      ).thenThrow(Exception('Upload failed'));

      await cubit.addProduct(
        product: product,
        imageBytes: imageBytes,
        imageName: 'product_image.png',
      );

      expect(cubit.state, isA<AddProductError>());

      final state = cubit.state as AddProductError;

      expect(state.message, 'Exception: Upload failed');

      verifyNever(repository.addProduct(any));
    });

    test('Should emit error when adding product fails', () async {
      when(
        repository.addProduct(any),
      ).thenThrow(Exception('Failed to add product'));

      await cubit.addProduct(product: product);

      expect(cubit.state, isA<AddProductError>());

      final state = cubit.state as AddProductError;

      expect(state.message, 'Exception: Failed to add product');

      verify(repository.addProduct(any)).called(1);
    });
  });
}
