abstract class CustomerSearchState {}

class CustomerSearchInitial extends CustomerSearchState {}

class CustomerSearchLoading extends CustomerSearchState {}

class CustomerSearchSuccess extends CustomerSearchState {
  final List clients;

  CustomerSearchSuccess(this.clients);
}

class CustomerSearchError extends CustomerSearchState {
  final String message;

  CustomerSearchError(this.message);
}