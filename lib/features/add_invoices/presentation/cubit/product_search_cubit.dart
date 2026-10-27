import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

import 'product_search_state.dart';

class ProductSearchCubit extends Cubit<ProductSearchState> {
  ProductSearchCubit(this.productsRepository)
      : super(ProductSearchInitial());

  final ProductsRepository productsRepository;

  Future<void> searchProducts(String query) async {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      emit(ProductSearchInitial());
      return;
    }

    emit(ProductSearchLoading());

    try {
      final List<ProductModel> products =
          await productsRepository.watchProducts().first;

      final filteredProducts = products.where((product) {
        final productName = product.name.toLowerCase();
        final productBarcode = product.barcode.toLowerCase();

        return productName.contains(search) ||
            productBarcode.contains(search);
      }).toList();

      emit(
        ProductSearchSuccess(filteredProducts),
      );
    } catch (e) {
      emit(
        ProductSearchError(
          e.toString(),
        ),
      );
    }
  }

  void clearSearch() {
    emit(ProductSearchInitial());
  }
}