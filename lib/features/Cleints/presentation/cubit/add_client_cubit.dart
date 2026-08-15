import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';

part 'add_client_state.dart';

class AddClientCubit extends Cubit<AddClientState> {
  final ClientsRepository repository;
  AddClientCubit(this.repository) : super(AddClientInitial());

  Future<void> addClient(CustomerModel client) async {
    emit(AddClientLoading());
    try {
      await repository.addClient(client);

      emit(AddClientSuccess());
    } catch (e) {
      emit(AddClientError(e.toString()));
    }
  }
}
