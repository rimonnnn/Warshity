import 'package:warshity/features/Cleints/data/data_source/clients_remote_data_source.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';

class ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;

  ClientsRepository(this.remoteDataSource);
  Stream<List<CustomerModel>> watchClients() {
    return remoteDataSource.watchClients();
  }

  Stream<CustomerModel> watchClient(String clientId) {
    return remoteDataSource.watchClient(clientId);
  }

  Future<void> addClient(CustomerModel client) async {
    await remoteDataSource.addClient(client);
  }

  Future<void> decreaseDebt({
    required String clientId,
    required num amount,
  }) async {
    await remoteDataSource.decreaseDebt(clientId: clientId, amount: amount);
  }

  Future<void> removeClient(String clientId) async {
    await remoteDataSource.removeClient(clientId);
  }
  Future<void> increaseDebt({
  required String clientId,
  required num amount,
}) async {
  await remoteDataSource.increaseDebt(
    clientId: clientId,
    amount: amount,
  );
}
}
