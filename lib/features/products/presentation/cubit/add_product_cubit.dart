import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

import 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ProductsRepository repository;

  AddProductCubit(this.repository) : super(AddProductInitial());

  Future<String> generateProductBarcode() async {
    return await repository.generateProductBarcode();
  }

  Future<List<String>> getCustomUnits() {
    return repository.getCustomUnits();
  }

  Future<void> addCustomUnit(String name) {
    return repository.addCustomUnit(name);
  }

  static const String defaultProductImage = "";

  Future<void> addProduct({
    required ProductModel product,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    emit(AddProductLoading());

    try {
      String imageUrl = defaultProductImage;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        imageUrl = await repository.uploadProductImage(
          imageBytes,
          imageName ?? 'product_image',
        );
      }

      final ProductModel productWithImage = ProductModel(
        id: product.id,
        name: product.name,
        barcode: product.barcode,
        category: product.category,
        price: product.price,
        quantity: product.quantity,
        unit: product.unit,
        imageUrl: imageUrl,
      );

      await repository.addProduct(productWithImage);

      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductError(e.toString()));
    }
  }
}
