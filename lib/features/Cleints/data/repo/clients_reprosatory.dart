import 'package:warshity/features/Cleints/data/data_source/clients_remote_data_source.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';

class ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;

  ClientsRepository(this.remoteDataSource);
  Stream<List<CustomerModel>> watchClients() {
    return remoteDataSource.watchClients();
  }

  Future<void> addClient(CustomerModel client) async {
    await remoteDataSource.addClient(client);
  }
}
