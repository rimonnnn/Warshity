import 'dart:io';

import 'package:warshity/features/products/data/datascource/products_remote_data_source.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

class ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepository(this.remoteDataSource);

  Stream<List<ProductModel>> watchProducts() {
    return remoteDataSource.watchProducts();
  }

  Future<String> uploadProductImage(File imageFile) async {
    return await remoteDataSource.uploadProductImage(imageFile);
  }

  Future<void> addProduct(ProductModel product) async {
    await remoteDataSource.addProduct(product);
  }
}