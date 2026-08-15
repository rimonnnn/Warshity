import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  final ClientsRepository reporsitory;
  ClientsCubit(this.reporsitory) : super(ClientsInitial());
  StreamSubscription<List<CustomerModel>>? _clientsSubscription;

   void watchClients() {
    emit(ClientsLoading());

    _clientsSubscription = reporsitory.watchClients().listen(
      (clients) {
        emit(ClientsLoaded(clients));
      },
      onError: (error) {
        emit(ClientsError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _clientsSubscription?.cancel();
    return super.close();
  }
  void changeFilter(int index) {
  // filtering logic
}
}
