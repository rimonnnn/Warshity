import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';

class ProductsRemoteDataSource {
  final FirebaseFirestore firestore;
  final SupabaseClient supabase;
  final AccountSharingRepository accountSharingRepository;

  ProductsRemoteDataSource(
    this.firestore,
    this.supabase,
    this.accountSharingRepository,
  );

  String get _currentUserId {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    return uid;
  }

  List<String> _normalizeIds(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<List<String>> _getActiveConnectionIds() async {
    return accountSharingRepository.getActiveConnectionIds();
  }

  bool _hasSharedConnectionAccess({
    required Map<String, dynamic> data,
    required List<String> activeConnectionIds,
  }) {
    final sharedConnectionIds = _normalizeIds(data['sharedConnectionIds']);

    if (sharedConnectionIds.isEmpty || activeConnectionIds.isEmpty) {
      return false;
    }

    return sharedConnectionIds.any(activeConnectionIds.contains);
  }

  Stream<List<ProductModel>> watchProducts() {
    final uid = _currentUserId;

    return accountSharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[];

      streams.add(
        firestore
            .collection('products')
            .where('userId', isEqualTo: uid)
            .snapshots(),
      );

      for (final connectionId in connectionIds) {
        if (connectionId.isEmpty) {
          continue;
        }

        streams.add(
          firestore
              .collection('products')
              .where('sharedConnectionIds', arrayContains: connectionId)
              .snapshots(),
        );
      }

      if (streams.length == 1) {
        return streams.first.map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc.id, doc.data()))
              .toList();
        });
      }

      return Stream.multi((controller) {
        // Each query owns its own result set. A document may match more than
        // one query, so removing it from one query must not remove it globally.
        final documentsByQuery =
            List<Map<String, DocumentSnapshot<Map<String, dynamic>>>>.generate(
          streams.length,
          (_) => <String, DocumentSnapshot<Map<String, dynamic>>>{},
        );
        final initialSnapshotsReceived = List<bool>.filled(
          streams.length,
          false,
        );

        final subscriptions =
            <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

        void emit() {
          // .first consumers (for example search) must receive the union only
          // after every query has supplied its initial snapshot.
          if (initialSnapshotsReceived.any((received) => !received)) {
            return;
          }

          final documents = <String, DocumentSnapshot<Map<String, dynamic>>>{};
          for (final queryDocuments in documentsByQuery) {
            documents.addAll(queryDocuments);
          }
          final products = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => ProductModel.fromFirestore(doc.id, doc.data()!))
              .toList();

          controller.add(products);
        }

        for (var streamIndex = 0; streamIndex < streams.length; streamIndex++) {
          final stream = streams[streamIndex];
          final subscription = stream.listen((snapshot) {
            final queryDocuments = documentsByQuery[streamIndex];
            queryDocuments
              ..clear()
              ..addEntries(
                snapshot.docs.map((doc) => MapEntry(doc.id, doc)),
              );
            initialSnapshotsReceived[streamIndex] = true;

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
    });
  }

  Future<String> uploadProductImage(
    Uint8List imageBytes,
    String originalFileName,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final safeFileName = originalFileName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );

    final filePath = 'products/${_currentUserId}/${timestamp}_$safeFileName';

    await supabase.storage
        .from('products')
        .uploadBinary(
          filePath,
          imageBytes,
          fileOptions: const FileOptions(upsert: false),
        );

    return supabase.storage.from('products').getPublicUrl(filePath);
  }

  Future<void> addProduct(ProductModel product) async {
    final uid = _currentUserId;

    final connectionIds = await _getActiveConnectionIds();

    final data = product.toFirestore();

    data['userId'] = uid;

    data['userIds'] = [uid];

    data['sharedConnectionIds'] = connectionIds;

    final ref = firestore.collection('products').doc();

    data['sharedDataId'] = ref.id;

    data.remove('sharedAccountId');

    await ref.set(data);
  }

  Future<void> deleteProduct(String productId) async {
    final uid = _currentUserId;

    final activeConnectionIds = await _getActiveConnectionIds();

    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      var hasAccess = ownerUid == uid;

      if (!hasAccess) {
        hasAccess = _hasSharedConnectionAccess(
          data: data,
          activeConnectionIds: activeConnectionIds,
        );
      }

      if (!hasAccess) {
        final legacyUserIds = _normalizeIds(data['userIds']);

        hasAccess = legacyUserIds.contains(uid);
      }

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      transaction.delete(productRef);
    });
  }

  Future<void> increaseProductQuantity(String productId) async {
    final uid = _currentUserId;

    final activeConnectionIds = await _getActiveConnectionIds();

    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      var hasAccess = ownerUid == uid;

      if (!hasAccess) {
        hasAccess = _hasSharedConnectionAccess(
          data: data,
          activeConnectionIds: activeConnectionIds,
        );
      }

      if (!hasAccess) {
        final legacyUserIds = _normalizeIds(data['userIds']);

        hasAccess = legacyUserIds.contains(uid);
      }

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      transaction.update(productRef, {'quantity': FieldValue.increment(1)});
    });
  }

  Future<void> decreaseProductQuantity(String productId) async {
    final uid = _currentUserId;

    final activeConnectionIds = await _getActiveConnectionIds();

    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      var hasAccess = ownerUid == uid;

      if (!hasAccess) {
        hasAccess = _hasSharedConnectionAccess(
          data: data,
          activeConnectionIds: activeConnectionIds,
        );
      }

      if (!hasAccess) {
        final legacyUserIds = _normalizeIds(data['userIds']);

        hasAccess = legacyUserIds.contains(uid);
      }

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      final currentQuantity = (data['quantity'] as num?)?.toInt() ?? 0;

      if (currentQuantity <= 0) {
        return;
      }

      transaction.update(productRef, {'quantity': currentQuantity - 1});
    });
  }

  Future<void> setProductQuantity({
    required String productId,
    required int quantity,
  }) async {
    if (quantity < 0) {
      throw Exception('quantity_cannot_be_negative'.tr());
    }

    final uid = _currentUserId;

    final activeConnectionIds = await _getActiveConnectionIds();

    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      var hasAccess = ownerUid == uid;

      if (!hasAccess) {
        hasAccess = _hasSharedConnectionAccess(
          data: data,
          activeConnectionIds: activeConnectionIds,
        );
      }

      if (!hasAccess) {
        final legacyUserIds = _normalizeIds(data['userIds']);

        hasAccess = legacyUserIds.contains(uid);
      }

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      transaction.update(productRef, {'quantity': quantity});
    });
  }
}
