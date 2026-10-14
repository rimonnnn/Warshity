import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';

import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';
import 'invoice_access_checker.dart';
import 'invoice_finalizer.dart';
import 'invoice_queries.dart';
import 'invoice_stock_checker.dart';

class InvoicesRemoteDataSource {
  final FirebaseFirestore firestore;

  InvoicesRemoteDataSource(this.firestore);

  String get _currentUserId {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    return uid;
  }

  AccountSharingRepository get _sharingRepository =>
      GetIt.I<AccountSharingRepository>();

  InvoiceQueries get _queries => InvoiceQueries(firestore, _sharingRepository);

  Future<List<String>> _getActiveConnectionIds() {
    return _sharingRepository.getActiveConnectionIds();
  }

  Future<bool> _hasAccess(Map<String, dynamic> data) async {
    return InvoiceAccessChecker.hasAccess(
      data: data,
      uid: _currentUserId,
      activeConnectionIds: await _getActiveConnectionIds(),
      requireActiveConnections: true,
    );
  }

  Future<void> createInvoice(InvoiceModel invoice) async {
    final uid = _currentUserId;
    final connectionIds = await _getActiveConnectionIds();
    final ref = firestore.collection('invoices').doc(invoice.invoiceId);

    final data = <String, dynamic>{
      ...invoice.toJson(),
      'userId': uid,
      'userIds': <String>[uid],
      'sharedConnectionIds': connectionIds,
      'sharedDataId': ref.id,
    };

    data.remove('sharedAccountId');

    await ref.set(data);
  }

  Future<void> finalizeInvoice(InvoiceModel invoice) async {
    await InvoiceFinalizer(firestore).finalize(
      invoice: invoice,
      uid: _currentUserId,
      activeConnectionIds: await _getActiveConnectionIds(),
    );
  }

  Stream<List<InvoiceModel>> watchInvoices() {
    return _queries.watch(uid: _currentUserId);
  }

  Stream<List<InvoiceModel>> watchClientInvoices(String customerId) {
    return _queries.watch(
      uid: _currentUserId,
      customerId: customerId,
      limit: 5,
    );
  }

  Stream<List<InvoiceModel>> watchAllClientInvoices(String customerId) {
    return _queries.watch(uid: _currentUserId, customerId: customerId);
  }

  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    final doc = await firestore.collection('invoices').doc(invoiceId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;

    if (!await _hasAccess(data)) {
      return null;
    }

    return InvoiceModel.fromJson(data);
  }

  Future<void> checkStock(InvoiceModel invoice) async {
    await InvoiceStockChecker(firestore).check(
      invoice: invoice,
      uid: _currentUserId,
      activeConnectionIds: await _getActiveConnectionIds(),
    );
  }

  Future<void> deleteInvoice(String invoiceId) async {
    final uid = _currentUserId;
    final invoiceRef = firestore.collection('invoices').doc(invoiceId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(invoiceRef);

      if (!snapshot.exists) {
        throw Exception('invoice_not_found'.tr());
      }

      final data = snapshot.data();

      InvoiceAccessChecker.ensureAccess(
        data: data,
        uid: uid,
        activeConnectionIds: await _getActiveConnectionIds(),
        errorKey: 'invoice_not_found',
      );

      final customerId = data?['customerId']?.toString() ?? '';

      if (customerId.isNotEmpty) {
        final clientRef = firestore.collection('clients').doc(customerId);
        final clientSnapshot = await transaction.get(clientRef);

        if (!clientSnapshot.exists) {
          throw Exception('client_not_found'.tr());
        }
      }

      transaction.delete(invoiceRef);
    });
  }
}
