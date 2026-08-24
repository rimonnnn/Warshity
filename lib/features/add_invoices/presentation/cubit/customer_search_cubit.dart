import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';

import 'customer_search_state.dart';

class CustomerSearchCubit extends Cubit<CustomerSearchState> {
  CustomerSearchCubit(this.clientsRepository)
      : super(CustomerSearchInitial());

  final ClientsRepository clientsRepository;

  Future<void> searchClients(String query) async {
    if (query.trim().isEmpty) {
      emit(CustomerSearchInitial());
      return;
    }

    emit(CustomerSearchLoading());

    try {
      final clients = await clientsRepository.watchClients().first;

      final search = query.trim().toLowerCase();

      final filteredClients = clients.where((client) {
       final name = client.name?.toLowerCase() ?? '';
        return name.contains(search);
      }).toList();

      emit(
        CustomerSearchSuccess(filteredClients),
      );
    } catch (e) {
      emit(
        CustomerSearchError(
          e.toString(),
        ),
      );
    }
  }

  void clearSearch() {
    emit(CustomerSearchInitial());
  }
}