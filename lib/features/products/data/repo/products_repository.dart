import 'dart:typed_data';

import 'package:warshity/features/products/data/datascource/products_remote_data_source.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

class ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepository(
    this.remoteDataSource,
  );

  // ============================================================
  // WATCH PRODUCTS
  // ============================================================

  Stream<List<ProductModel>> watchProducts() {
    return remoteDataSource.watchProducts();
  }

  // ============================================================
  // UPLOAD IMAGE
  // ============================================================

  Future<String> uploadProductImage(
    Uint8List imageBytes,
    String imageName,
  ) async {
    return await remoteDataSource.uploadProductImage(
      imageBytes,
      imageName,
    );
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<void> addProduct(
    ProductModel product,
  ) async {
    await remoteDataSource.addProduct(
      product,
    );
  }
  Future<void> deleteProduct(String productId) async {
  await remoteDataSource.deleteProduct(productId);
}
}