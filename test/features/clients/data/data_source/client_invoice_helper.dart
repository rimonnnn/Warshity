import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/invoice_payment_allocator.dart';
import 'client_access_checker.dart';
import 'client_value_parsers.dart';

typedef InvoiceRef = DocumentReference<Map<String, dynamic>>;
typedef InvoiceSnap = DocumentSnapshot<Map<String, dynamic>>;

/// أدوات مشتركة للتعامل مع فواتير العميل (تسديد الديون / المطابقة).
class ClientInvoiceHelper {
  const ClientInvoiceHelper._();

  static Future<List<InvoiceRef>> referencesForClient(
    FirebaseFirestore firestore,
    String clientId, {
    required String uid,
    required List<String> activeConnectionIds,
  }) async {
    final invoices = firestore.collection('invoices');
    final queries = <Query<Map<String, dynamic>>>[
      invoices
          .where('userId', isEqualTo: uid)
          .where('customerId', isEqualTo: clientId),

      invoices
          .where('userIds', arrayContains: uid)
          .where('customerId', isEqualTo: clientId),
    ];

    for (final connectionId in activeConnectionIds) {
      if (connectionId.isEmpty) continue;
      queries.add(
        invoices
            .where('sharedConnectionIds', arrayContains: connectionId)
            .where('customerId', isEqualTo: clientId),
      );
    }

    final querySnapshots = await Future.wait(
      queries.map((query) => query.get()),
    );
    final references = <String, InvoiceRef>{};
    for (final querySnapshot in querySnapshots) {
      for (final document in querySnapshot.docs) {
        references[document.id] = document.reference;
      }
    }
    return references.values.toList();
  }

  /// يقرأ داخل المعاملة الفواتير الخاصة بالعميل والمسموح بها فقط.
  static Future<List<InvoiceSnap>> readClientInvoices(
    Transaction transaction,
    List<InvoiceRef> refs, {
    required String clientId,
    required String uid,
    required List<String> activeConnectionIds,
  }) async {
    final snapshots = <InvoiceSnap>[];

    for (final invoiceRef in refs) {
      final snapshot = await transaction.get(invoiceRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) continue;
      if (data['customerId']?.toString() != clientId) continue;
      if (!ClientAccessChecker.canAccessRecord(
        data: data,
        uid: uid,
        activeConnectionIds: activeConnectionIds,
      )) {
        continue;
      }
      snapshots.add(snapshot);
    }

    return snapshots;
  }

  static List<InvoicePaymentEntry> toEntries(Iterable<InvoiceSnap> snapshots) {
    return snapshots.map((snapshot) {
      final data = snapshot.data()!;
      final total = ClientValueParsers.doubleValue(data['total']);
      return InvoicePaymentEntry(
        invoiceId: snapshot.id,
        createdAt: ClientValueParsers.invoiceDate(data),
        total: total,
        paidAmount: total > 0
            ? ClientValueParsers.normalizedPaidAmount(data, total)
            : 0.0,
      );
    }).toList();
  }

  /// هل المبلغ المدفوع أو المتبقي المخزّن يختلف عن المحسوب؟
  static bool amountsNeedUpdate(
    Map<String, dynamic> data,
    num paidAmount,
    num remainingAmount,
  ) {
    final storedPaid = data['paidAmount'];
    final storedRemaining = data['remainingAmount'];

    final paidNeedsUpdate =
        storedPaid is! num ||
        (storedPaid.toDouble() - paidAmount).abs() > 0.005;
    final remainingNeedsUpdate =
        storedRemaining is! num ||
        (storedRemaining.toDouble() - remainingAmount).abs() > 0.005;

    return paidNeedsUpdate || remainingNeedsUpdate;
  }
}
