import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warshity/features/Cleints/data/customer_model.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit() : super(ClientsInitial());
}
