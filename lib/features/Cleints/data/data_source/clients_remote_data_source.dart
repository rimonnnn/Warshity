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
              .map((doc) => CustomerModel.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<CustomerModel> watchClient(String clientId) {
    return firestore.collection('clients').doc(clientId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Client not found');
      }

      return CustomerModel.fromFirestore(doc.id, doc.data()!);
    });
  }

  Future<void> addClient(CustomerModel client) async {
    await firestore.collection("clients").add(client.toFirestore());
  }

  Future<void> decreaseDebt({
    required String clientId,
    required num amount,
  }) async {
    final clientRef = firestore.collection('clients').doc(clientId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(clientRef);

      if (!snapshot.exists) {
        throw Exception('Client not found');
      }

      final data = snapshot.data() ?? {};

      final currentBalance = (data['balance'] as num?) ?? 0;

      if (amount <= 0) {
        throw Exception('Invalid debt amount');
      }

      if (amount > currentBalance) {
        throw Exception('Debt payment exceeds current balance');
      }

      final newBalance = currentBalance - amount;

      transaction.update(clientRef, {
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      });
    });
  }

  Future<void> removeClient(String clientId) async {
    await firestore.collection("clients").doc(clientId).delete();
  }
  Future<void> increaseDebt({
  required String clientId,
  required num amount,
}) async {
  final clientRef = firestore.collection('clients').doc(clientId);

  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(clientRef);

    if (!snapshot.exists) {
      throw Exception('Client not found');
    }

    final data = snapshot.data() ?? {};
    final currentBalance = (data['balance'] as num?) ?? 0;

    if (amount <= 0) return;

    final newBalance = currentBalance + amount;

    transaction.update(clientRef, {
      'balance': newBalance,
      'hasDebt': newBalance > 0,
    });
  });
}
}
