abstract class ProductSearchState {}

class ProductSearchInitial extends ProductSearchState {}

class ProductSearchLoading extends ProductSearchState {}

class ProductSearchSuccess extends ProductSearchState {
  final List products;

  ProductSearchSuccess(this.products);
}

class ProductSearchError extends ProductSearchState {
  final String message;

  ProductSearchError(this.message);
}