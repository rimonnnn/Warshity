import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/invoice_payment_allocator.dart';
import 'client_access_checker.dart';
import 'client_invoice_helper.dart';

/// زيادة وتخفيض مديونية العميل (مع توزيع الدفعة على الفواتير).
class ClientDebtService {
  final FirebaseFirestore firestore;
  final Future<List<String>> Function() getActiveConnectionIds;

  ClientDebtService(this.firestore, this.getActiveConnectionIds);

  Future<void> decreaseDebt({
    required String uid,
    required String clientId,
    required num amount,
  }) async {
    if (amount <= 0) {
      throw Exception('invalid_debt_amount'.tr());
    }

    final activeConnectionIds = await getActiveConnectionIds();
    final invoiceRefs = await ClientInvoiceHelper.referencesForClient(
      firestore,
      clientId,
      uid: uid,
      activeConnectionIds: activeConnectionIds,
    );
    final clientRef = firestore.collection('clients').doc(clientId);

    await firestore.runTransaction((transaction) async {
      final clientSnapshot = await transaction.get(clientRef);

      if (!clientSnapshot.exists || clientSnapshot.data() == null) {
        throw Exception('client_not_found'.tr());
      }

      final clientData = clientSnapshot.data()!;
      if (!ClientAccessChecker.canAccessRecord(
        data: clientData,
        uid: uid,
        activeConnectionIds: activeConnectionIds,
      )) {
        throw Exception('client_not_found'.tr());
      }

      final currentBalance = (clientData['balance'] as num?)?.toDouble() ?? 0.0;
      final paymentAmount = amount.toDouble();

      if (paymentAmount > currentBalance) {
        throw Exception('debt_payment_exceeds_balance'.tr());
      }

      final invoiceSnapshots = await ClientInvoiceHelper.readClientInvoices(
        transaction,
        invoiceRefs,
        clientId: clientId,
        uid: uid,
        activeConnectionIds: activeConnectionIds,
      );

      final allocationResult = InvoicePaymentAllocator.allocate(
        invoices: ClientInvoiceHelper.toEntries(invoiceSnapshots),
        paymentAmount: paymentAmount,
      );
      final allocationsByInvoiceId = {
        for (final allocation in allocationResult.allocations)
          allocation.invoiceId: allocation,
      };

      for (final invoiceSnapshot in invoiceSnapshots) {
        final allocation = allocationsByInvoiceId[invoiceSnapshot.id];
        if (allocation == null) continue;

        final needsUpdate =
            allocation.appliedAmount > 0.005 ||
            ClientInvoiceHelper.amountsNeedUpdate(
              invoiceSnapshot.data()!,
              allocation.paidAmount,
              allocation.remainingAmount,
            );

        if (needsUpdate) {
          transaction.update(invoiceSnapshot.reference, {
            'paidAmount': allocation.paidAmount,
            'remainingAmount': allocation.remainingAmount,
          });
        }
      }

      final newBalance = (currentBalance - paymentAmount)
          .clamp(0.0, double.infinity)
          .toDouble();

      transaction.update(clientRef, {
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      });
    });
  }

  Future<void> increaseDebt({
    required String uid,
    required String clientId,
    required num amount,
  }) async {
    final clientRef = firestore.collection('clients').doc(clientId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(clientRef);

      if (!snapshot.exists) {
        throw Exception('client_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      if (data['userId']?.toString() != uid) {
        final hasAccess = ClientAccessChecker.hasSharedAccess(
          data: data,
          uid: uid,
          activeConnectionIds: await getActiveConnectionIds(),
        );

        if (!hasAccess) {
          throw Exception('client_not_found'.tr());
        }
      }

      final currentBalance = (data['balance'] as num?) ?? 0;

      if (amount <= 0) {
        return;
      }

      final newBalance = currentBalance + amount;

      transaction.update(clientRef, {
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      });
    });
  }
}
