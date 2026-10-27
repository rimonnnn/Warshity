import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository repository;

  ProductsCubit(this.repository) : super(ProductsInitial());

  StreamSubscription<List<ProductModel>>? _productsSubscription;

  List<ProductModel> _allProducts = [];
  String _searchQuery = '';

  List<ProductModel> get allProducts => List.unmodifiable(_allProducts);

  void watchProducts() {
    emit(ProductsLoading());

    _productsSubscription?.cancel();

    _productsSubscription = repository.watchProducts().listen(
      (products) {
        _allProducts = products;
        _emitFilteredProducts();
      },
      onError: (error) {
        emit(ProductsError(error.toString()));
      },
    );
  }

  void searchProducts(String query) {
    _searchQuery = query.trim().toLowerCase();

    if (state is ProductsSuccess) {
      _emitFilteredProducts();
    }
  }

  void _emitFilteredProducts() {
    if (_searchQuery.isEmpty) {
      emit(ProductsSuccess(List.of(_allProducts)));
      return;
    }

    final filteredProducts = _allProducts.where((product) {
      final name = product.name.toLowerCase();
      final barcode = product.barcode.toLowerCase();

      return name.contains(_searchQuery) || barcode.contains(_searchQuery);
    }).toList();

    emit(ProductsSuccess(filteredProducts));
  }

  Future<void> increaseQuantity(String productId) async {
    await repository.increaseProductQuantity(productId);
  }

  Future<void> decreaseQuantity(String productId) async {
    await repository.decreaseProductQuantity(productId);
  }

  Future<void> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    await repository.setProductQuantity(
      productId: productId,
      quantity: quantity,
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
