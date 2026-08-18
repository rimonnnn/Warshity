import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository repository;

  ProductsCubit(this.repository) : super(ProductsInitial());

  StreamSubscription<List<ProductModel>>? _productsSubscription;

  void watchProducts() {
    emit(ProductsLoading());

    _productsSubscription?.cancel();

    _productsSubscription = repository.watchProducts().listen(
      (products) {
        emit(ProductsSuccess(products));
      },
      onError: (error) {
        emit(
          ProductsError(error.toString()),
        );
      },
    );
  }
  Future<void> deleteProduct(String productId) async {
  try {
    await repository.deleteProduct(productId);
  } catch (e) {
    rethrow;
  }
}

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}