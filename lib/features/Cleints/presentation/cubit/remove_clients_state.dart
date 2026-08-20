import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/Cleints/presentation/cubit/remove_clients_cubit.dart';

class RemoveClientCubit extends Cubit<RemoveClientState> {
  final ClientsRepository repository;

  RemoveClientCubit(this.repository)
      : super(const RemoveClientInitial());

  Future<void> removeClient({
    required String clientId,
  }) async {
    emit(
      const RemoveClientAction(
        status: RemoveClientStatus.loading,
      ),
    );

    try {
      await repository.removeClient(clientId);

      emit(
        const RemoveClientAction(
          status: RemoveClientStatus.success,
        ),
      );
    } catch (e) {
      emit(
        RemoveClientAction(
          status: RemoveClientStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}