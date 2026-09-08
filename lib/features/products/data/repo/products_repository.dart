import 'dart:typed_data';

import 'package:warshity/features/products/data/datascource/products_remote_data_source.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

class ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepository(this.remoteDataSource);

  Stream<List<ProductModel>> watchProducts() {
    return remoteDataSource.watchProducts();
  }

  Future<String> uploadProductImage(
    Uint8List imageBytes,
    String imageName,
  ) async {
    return await remoteDataSource.uploadProductImage(
      imageBytes,
      imageName,
    );
  }

  Future<void> addProduct(ProductModel product) async {
    await remoteDataSource.addProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await remoteDataSource.deleteProduct(productId);
  }

  Future<void> increaseProductQuantity(String productId) async {
    await remoteDataSource.increaseProductQuantity(productId);
  }

  Future<void> decreaseProductQuantity(String productId) async {
    await remoteDataSource.decreaseProductQuantity(productId);
  }

  Future<void> setProductQuantity({
    required String productId,
    required int quantity,
  }) async {
    await remoteDataSource.setProductQuantity(
      productId: productId,
      quantity: quantity,
    );
  }
}