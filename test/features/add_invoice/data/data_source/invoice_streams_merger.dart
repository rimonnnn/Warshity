import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:warshity/features/invoices/data/models/invoice_model.dart';

typedef InvoiceQuerySnapshot = QuerySnapshot<Map<String, dynamic>>;
typedef InvoiceDocSnapshot = DocumentSnapshot<Map<String, dynamic>>;

/// دمج عدة Streams من Firestore في Stream واحد بدون تكرار.
class InvoiceStreamsMerger {
  const InvoiceStreamsMerger._();

  static List<InvoiceModel> mapDocuments(
    Iterable<InvoiceDocSnapshot> documents, {
    int? limit,
  }) {
    final uniqueDocuments = <String, InvoiceDocSnapshot>{};
    for (final document in documents) {
      uniqueDocuments[document.id] = document;
    }

    final invoices =
        uniqueDocuments.values
            .where((document) => document.exists && document.data() != null)
            .map((document) => InvoiceModel.fromJson(document.data()!))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return limit == null ? invoices : invoices.take(limit).toList();
  }

  static Stream<List<InvoiceModel>> merge(
    List<Stream<InvoiceQuerySnapshot>> streams, {
    int? limit,
  }) {
    if (streams.length == 1) {
      return streams.first.map(
        (snapshot) => mapDocuments(snapshot.docs, limit: limit),
      );
    }

    return Stream.multi((controller) {
      final documentsByQuery = List<Map<String, InvoiceDocSnapshot>>.generate(
        streams.length,
        (_) => <String, InvoiceDocSnapshot>{},
      );
      final initialSnapshotsReceived = List<bool>.filled(streams.length, false);
      final subscriptions = <StreamSubscription<InvoiceQuerySnapshot>>[];

      void emit() {
        if (initialSnapshotsReceived.any((received) => !received)) return;

        final uniqueDocuments = <String, InvoiceDocSnapshot>{};
        for (final queryDocuments in documentsByQuery) {
          uniqueDocuments.addAll(queryDocuments);
        }

        controller.add(mapDocuments(uniqueDocuments.values, limit: limit));
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
