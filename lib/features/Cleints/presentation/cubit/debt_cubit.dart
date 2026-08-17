import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';

part 'debt_state.dart';

class DebtCubit extends Cubit<DebtState> {
  final ClientsRepository repository;

  DebtCubit(this.repository) : super(const DebtInitial());

  Future<void> decreaseDebt({
    required String clientId,
    required num amount,
  }) async {
    emit(const DebtAction(status: DebtActionStatus.loading));

    try {
      await repository.decreaseDebt(clientId: clientId, amount: amount);

      emit(const DebtAction(status: DebtActionStatus.success));
    } catch (e) {
      emit(
        DebtAction(
          status: DebtActionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }




  
}


