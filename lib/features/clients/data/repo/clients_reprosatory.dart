import 'package:warshity/features/clients/data/data_source/clients_remote_data_source.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';

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

  /// Repairs historic payments that lowered a customer's debt but were not
  /// written back to the corresponding invoice paid/remaining amounts.
  Future<int> reconcileInvoiceOutstandingAmountsWithClientBalances() {
    return remoteDataSource.reconcileInvoiceOutstandingAmountsWithClientBalances();
  }

  Future<void> increaseDebt({
    required String clientId,
    required num amount,
  }) async {
    await remoteDataSource.increaseDebt(clientId: clientId, amount: amount);
  }

  Future<void> removeClient(String clientId) async {
    await remoteDataSource.removeClient(clientId);
  }
}
