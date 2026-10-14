import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';
import 'invoice_streams_merger.dart';

/// استعلامات مراقبة الفواتير (فواتيري + المشتركة معي).
class InvoiceQueries {
  final FirebaseFirestore firestore;
  final AccountSharingRepository sharingRepository;

  InvoiceQueries(this.firestore, this.sharingRepository);

  /// يراقب كل الفواتير، أو فواتير عميل معيّن إذا مُرّر [customerId].
  Stream<List<InvoiceModel>> watch({
    required String uid,
    String? customerId,
    int? limit,
  }) {
    return sharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      Query<Map<String, dynamic>> byCustomer(Query<Map<String, dynamic>> q) {
        return customerId == null
            ? q
            : q.where('customerId', isEqualTo: customerId);
      }

      final invoices = firestore.collection('invoices');

      final streams = <Stream<InvoiceQuerySnapshot>>[
        byCustomer(invoices.where('userId', isEqualTo: uid)).snapshots(),
      ];

      for (final connectionId in connectionIds) {
        if (connectionId.isEmpty) continue;
        streams.add(
          byCustomer(
            invoices.where('sharedConnectionIds', arrayContains: connectionId),
          ).snapshots(),
        );
      }

      return InvoiceStreamsMerger.merge(streams, limit: limit);
    });
  }
}
