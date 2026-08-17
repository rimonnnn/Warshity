import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

import 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ProductsRepository repository;

  AddProductCubit(this.repository)
      : super(AddProductInitial());

  // ============================================================
  // DEFAULT IMAGE
  // ============================================================

  static const String defaultProductImage =
      'https://jcyynfpomdtlyrnrmrng.supabase.co/storage/v1/object/public/products/products/1786959235052_scaled_Background__2_.png';

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<void> addProduct({
    required ProductModel product,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    emit(AddProductLoading());

    try {
      String imageUrl = defaultProductImage;

      // ==========================================================
      // UPLOAD SELECTED IMAGE
      // ==========================================================

      if (imageBytes != null &&
          imageBytes.isNotEmpty) {
        imageUrl = await repository.uploadProductImage(
          imageBytes,
          imageName ?? 'product_image',
        );
      }

      // ==========================================================
      // CREATE PRODUCT
      // ==========================================================

      final ProductModel productWithImage =
          ProductModel(
        id: product.id,
        name: product.name,
        barcode: product.barcode,
        category: product.category,
        price: product.price,
        quantity: product.quantity,
        unit: product.unit,
        imageUrl: imageUrl,
      );

      // ==========================================================
      // SAVE TO FIRESTORE
      // ==========================================================

      await repository.addProduct(
        productWithImage,
      );

      // ==========================================================
      // SUCCESS
      // ==========================================================

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