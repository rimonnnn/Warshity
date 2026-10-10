import 'package:warshity/features/global_search/data/model/global_search_result.dart';

sealed class GlobalSearchState {
  const GlobalSearchState();
}

class GlobalSearchInitial extends GlobalSearchState {
  const GlobalSearchInitial();
}

class GlobalSearchLoading extends GlobalSearchState {
  const GlobalSearchLoading();
}

class GlobalSearchSuccess extends GlobalSearchState {
  final List<GlobalSearchResult> clients;
  final List<GlobalSearchResult> products;

  const GlobalSearchSuccess({required this.clients, required this.products});

  bool get hasResults => clients.isNotEmpty || products.isNotEmpty;
}

class GlobalSearchFailure extends GlobalSearchState {
  final String message;

  const GlobalSearchFailure({required this.message});
}
