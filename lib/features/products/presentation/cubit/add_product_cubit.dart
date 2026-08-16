import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

import 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ProductsRepository repository;

  AddProductCubit(this.repository) : super(AddProductInitial());

  Future<void> addProduct({
    required ProductModel product,
    File? imageFile,
  }) async {
    emit(AddProductLoading());

    try {
      String imageUrl = '';

      // Upload image to Supabase
      if (imageFile != null) {
        imageUrl = await repository.uploadProductImage(imageFile);
      }

      // Create product with image URL
      final productWithImage = ProductModel(
        id: product.id,
        name: product.name,
        barcode: product.barcode,
        category: product.category,
        price: product.price,
        quantity: product.quantity,
        unit: product.unit,
        imageUrl: imageUrl,
      );

      // Save product to Firestore
      await repository.addProduct(productWithImage);

      emit(AddProductSuccess());
    } catch (e) {
      emit(
        AddProductError(
          e.toString(),
        ),
      );
    }
  }
}