import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:warshity/features/clients/data/model/customer_model.dart';

import '../utils/invoice_payment_allocator.dart';
import 'client_access_checker.dart';
import 'client_invoice_helper.dart';
import 'client_value_parsers.dart';

/// مطابقة مبالغ الفواتير وإحصائيات العملاء مع رصيد كل عميل.
class ClientReconciler {
  final FirebaseFirestore firestore;

  ClientReconciler(this.firestore);

  /// يرجع عدد السجلات التي تم تحديثها.
  Future<int> reconcile({
    required List<CustomerModel> clients,
    required String uid,
    required List<String> activeConnectionIds,
  }) async {
    var updatedRecordCount = 0;

    for (final client in clients) {
      final clientId = client.id;
      if (clientId == null || clientId.isEmpty) continue;

      final invoiceRefs = await ClientInvoiceHelper.referencesForClient(
        firestore,
        clientId,
        uid: uid,
        activeConnectionIds: activeConnectionIds,
      );

      updatedRecordCount += await firestore.runTransaction<int>(
        (transaction) => _reconcileClient(
          transaction,
          clientId: clientId,
          invoiceRefs: invoiceRefs,
          uid: uid,
          activeConnectionIds: activeConnectionIds,
        ),
      );
    }

    return updatedRecordCount;
  }

  Future<int> _reconcileClient(
    Transaction transaction, {
    required String clientId,
    required List<InvoiceRef> invoiceRefs,
    required String uid,
    required List<String> activeConnectionIds,
  }) async {
    final clientRef = firestore.collection('clients').doc(clientId);
    final clientSnapshot = await transaction.get(clientRef);
    if (!clientSnapshot.exists || clientSnapshot.data() == null) return 0;

    final clientData = clientSnapshot.data()!;
    if (!ClientAccessChecker.canAccessRecord(
      data: clientData,
      uid: uid,
      activeConnectionIds: activeConnectionIds,
    )) {
      return 0;
    }

    final invoiceSnapshots = await ClientInvoiceHelper.readClientInvoices(
      transaction,
      invoiceRefs,
      clientId: clientId,
      uid: uid,
      activeConnectionIds: activeConnectionIds,
    );

    final customerBalance = (clientData['balance'] as num?)?.toDouble() ?? 0.0;
    final actualOrderCount = invoiceSnapshots.length;
    final actualTotalPurchases = invoiceSnapshots.fold<double>(
      0,
      (sum, snapshot) =>
          sum + ClientValueParsers.doubleValue(snapshot.data()?['total']),
    );

    final allocationResult = InvoicePaymentAllocator.reconcile(
      invoices: ClientInvoiceHelper.toEntries(invoiceSnapshots),
      customerBalance: customerBalance,
    );
    final allocationsByInvoiceId = {
      for (final allocation in allocationResult.allocations)
        allocation.invoiceId: allocation,
    };

    var changed = 0;
    for (final invoiceSnapshot in invoiceSnapshots) {
      final allocation = allocationsByInvoiceId[invoiceSnapshot.id];
      if (allocation == null) continue;

      if (ClientInvoiceHelper.amountsNeedUpdate(
        invoiceSnapshot.data()!,
        allocation.paidAmount,
        allocation.remainingAmount,
      )) {
        transaction.update(invoiceSnapshot.reference, {
          'paidAmount': allocation.paidAmount,
          'remainingAmount': allocation.remainingAmount,
        });
        changed++;
      }
    }

    final storedTotalPurchases = clientData['totalPurchases'];
    final storedOrderCount = clientData['orderCount'];
    final purchaseTotalNeedsUpdate =
        storedTotalPurchases is! num ||
        (storedTotalPurchases.toDouble() - actualTotalPurchases).abs() > 0.005;
    final orderCountNeedsUpdate =
        storedOrderCount is! num || storedOrderCount.toInt() != actualOrderCount;

    if (purchaseTotalNeedsUpdate || orderCountNeedsUpdate) {
      transaction.update(clientRef, {
        'totalPurchases': actualTotalPurchases,
        'orderCount': actualOrderCount,
      });
      changed++;
    }

    return changed;
  }
}
