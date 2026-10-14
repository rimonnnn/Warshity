import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';

typedef _QuerySnap = QuerySnapshot<Map<String, dynamic>>;
typedef _DocSnap = DocumentSnapshot<Map<String, dynamic>>;

/// مراقبة العملاء (عملائي + المشتركين معي) ودمجهم بدون تكرار.
class ClientsWatcher {
  final FirebaseFirestore firestore;
  final AccountSharingRepository sharingRepository;

  ClientsWatcher(this.firestore, this.sharingRepository);

  Stream<List<CustomerModel>> watchClients(String uid) {
    return sharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      final clients = firestore.collection('clients');

      final streams = <Stream<_QuerySnap>>[
        clients.where('userId', isEqualTo: uid).snapshots(),
      ];

      for (final connectionId in connectionIds) {
        if (connectionId.isEmpty) continue;
        streams.add(
          clients
              .where('sharedConnectionIds', arrayContains: connectionId)
              .snapshots(),
        );
      }

      if (streams.length == 1) {
        return streams.first.map(_mapSnapshot);
      }

      return _merge(streams);
    });
  }

  List<CustomerModel> _mapSnapshot(_QuerySnap snapshot) {
    return snapshot.docs
        .map((doc) => CustomerModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Stream<List<CustomerModel>> _merge(List<Stream<_QuerySnap>> streams) {
    return Stream.multi((controller) {
      final documentsByQuery = List<Map<String, _DocSnap>>.generate(
        streams.length,
        (_) => <String, _DocSnap>{},
      );
      final initialSnapshotsReceived = List<bool>.filled(streams.length, false);
      final subscriptions = <StreamSubscription<_QuerySnap>>[];

      void emit() {
        if (initialSnapshotsReceived.any((received) => !received)) return;

        final documents = <String, _DocSnap>{};
        for (final queryDocuments in documentsByQuery) {
          documents.addAll(queryDocuments);
        }

        controller.add(
          documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => CustomerModel.fromFirestore(doc.id, doc.data()!))
              .toList(),
        );
      }

      for (var index = 0; index < streams.length; index++) {
        final subscription = streams[index].listen((snapshot) {
          final queryDocuments = documentsByQuery[index];
          queryDocuments.clear();
          for (final document in snapshot.docs) {
            queryDocuments[document.id] = document;
          }

          initialSnapshotsReceived[index] = true;
          emit();
        }, onError: controller.addError);

        subscriptions.add(subscription);
      }

      controller.onCancel = () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      };
    });
  }
}
