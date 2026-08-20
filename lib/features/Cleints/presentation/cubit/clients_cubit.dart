import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  final ClientsRepository repository;

  ClientsCubit(this.repository) : super(ClientsInitial());

  StreamSubscription<List<CustomerModel>>? _clientsSubscription;

  void watchClients() {
    _clientsSubscription?.cancel();

    emit(ClientsLoading());

    _clientsSubscription = repository.watchClients().listen(
      (clients) {
        emit(ClientsLoaded(clients: clients, displayedClients: clients));
      },
      onError: (error) {
        emit(ClientsError(error.toString()));
      },
    );
  }

  void searchClients(String query) {
    final currentState = state;

    if (currentState is! ClientsLoaded) return;

    emit(currentState.copyWith(searchQuery: query));

    applySearchAndFilter();
  }

  void filterClients(ClientFilter filter) {
    final currentState = state;

    if (currentState is! ClientsLoaded) return;

    emit(currentState.copyWith(filter: filter));

    applySearchAndFilter();
  }

  void applySearchAndFilter() {
    final currentState = state;

    if (currentState is! ClientsLoaded) return;

    final query = currentState.searchQuery.trim().toLowerCase();

    var result = List<CustomerModel>.from(currentState.clients);

    // Search
    if (query.isNotEmpty) {
      result = result.where((client) {
        final name = client.name!.toLowerCase();
        final phone = client.phone;

        return name.contains(query) || phone!.contains(query);
      }).toList();
    }

    // Filter
    switch (currentState.filter) {
      case ClientFilter.all:
        break;

      case ClientFilter.hasDebt:
        result = result.where((client) {
          return client.balance! > 0;
        }).toList();

      case ClientFilter.noDebt:
        result = result.where((client) {
          return client.balance! <= 0;
        }).toList();
    }

    emit(currentState.copyWith(displayedClients: result));
  }
  
 

  @override
  Future<void> close() async {
    await _clientsSubscription?.cancel();
    return super.close();
  }
}

enum ClientFilter { all, hasDebt, noDebt }
