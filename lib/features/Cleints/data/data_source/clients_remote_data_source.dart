import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';

class ClientsRemoteDataSource {
  final FirebaseFirestore firestore;

  ClientsRemoteDataSource(this.firestore);

  Stream<List<CustomerModel>> watchClients() {
    return firestore
        .collection('clients')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CustomerModel.fromFirestore(
                doc.id,
                doc.data(),
                 
                 ),
                 )
              .toList(),
        );
  }

  Future<void> addClient(CustomerModel client) async {
    await firestore.collection("clients").add(client.toFirestore());
  }
}
