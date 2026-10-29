import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warshity/core/errors/app_failure.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

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

  List<String> _normalizeCustomUnits(dynamic value) {
    if (value is! List) return <String>[];

    final result = <String>[];
    final seen = <String>{};

    for (final item in value) {
      if (item is! String) continue;
      final unit = item.trim();
      if (unit.isEmpty) continue;

      if (seen.add(unit.toLowerCase())) {
        result.add(unit);
      }
    }

    return result;
  }

  Future<List<String>> getCustomUnits() async {
    final uid = _currentUserId;
    final snapshot = await firestore.collection('users').doc(uid).get();

    if (!snapshot.exists) return <String>[];

    return _normalizeCustomUnits(snapshot.data()?['customUnits']);
  }

  Future<void> addCustomUnit(String name) async {
    final uid = _currentUserId;
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('اسم الوحدة لا يمكن أن يكون فارغًا.');
    }
    if (normalizedName.length > 40) {
      throw ArgumentError('اسم الوحدة يجب ألا يزيد عن 40 حرفًا.');
    }

    final userRef = firestore.collection('users').doc(uid);

    await firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception(
          'ملف المستخدم غير موجود في Firestore. سجّل الدخول مرة أخرى ثم حاول.',
        );
      }

      final data = snapshot.data() ?? <String, dynamic>{};
      final units = _normalizeCustomUnits(data['customUnits']);
      final duplicate = units.any(
        (unit) => unit.toLowerCase() == normalizedName.toLowerCase(),
      );
      if (duplicate) return;

      if (units.length >= 100) {
        throw Exception('لا يمكن إضافة أكثر من 100 وحدة مخصصة.');
      }

      transaction.update(userRef, {
        'customUnits': <String>[...units, normalizedName],
      });
    });
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      // Never throw during widget build: report as a stream error instead.
      return Stream.error(const UnauthenticatedException());
    }

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
              ..addEntries(snapshot.docs.map((doc) => MapEntry(doc.id, doc)));
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

  Future<String> generateProductBarcode() async {
    final uid = _currentUserId;

    final counterRef = firestore
        .collection('appCounters')
        .doc('productBarcode');

    final registry = firestore.collection('productBarcodeRegistry');

    for (var attempt = 0; attempt < 100; attempt++) {
      String? code;

      try {
        code = await firestore.runTransaction<String?>((transaction) async {
          final counterSnapshot = await transaction.get(counterRef);

          final currentValue =
              (counterSnapshot.data()?['value'] as num?)?.toInt() ?? 0;

          final nextValue = currentValue + 1;

          final candidate = 'MST-${nextValue.toString().padLeft(6, '0')}';

          final reservationRef = registry.doc(candidate);
          final reservationSnapshot = await transaction.get(reservationRef);

          transaction.set(counterRef, {
            'value': nextValue,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          if (reservationSnapshot.exists) {
            return null;
          }

          transaction.set(reservationRef, {
            'code': candidate,
            'userId': uid,
            'status': 'reserved',
            'createdAt': FieldValue.serverTimestamp(),
          });

          return candidate;
        });
      } on FirebaseException catch (e) {
        throw Exception(
          'Barcode reservation transaction failed: [${e.code}] ${e.message}',
        );
      } catch (e) {
        throw Exception('Barcode reservation transaction failed: $e');
      }

      if (code == null) {
        continue;
      }

      try {
        final existingProducts = await firestore
            .collection('products')
            .where('barcode', isEqualTo: code)
            .where('userId', isEqualTo: uid)
            .limit(1)
            .get();

        if (existingProducts.docs.isEmpty) {
          return code;
        }
      } on FirebaseException catch (e) {
        throw Exception(
          'Barcode uniqueness check failed: [${e.code}] ${e.message}',
        );
      }
    }

    throw Exception('Unable to generate a unique product code.');
  }

  Future<void> addProduct(ProductModel product) async {
    final uid = _currentUserId;
    final barcode = product.barcode.trim();

    if (barcode.isEmpty) {
      throw Exception('Product code is required.');
    }

    final connectionIds = await _getActiveConnectionIds();

    final reservationRef = firestore
        .collection('productBarcodeRegistry')
        .doc(barcode);

    final productRef = firestore.collection('products').doc();

    final data = product.toFirestore();

    data['barcode'] = barcode;
    data['userId'] = uid;
    data['userIds'] = [uid];
    data['sharedConnectionIds'] = connectionIds;
    data['sharedDataId'] = productRef.id;

    data.remove('sharedAccountId');

    await firestore.runTransaction<void>((transaction) async {
      final reservationSnapshot = await transaction.get(reservationRef);

      if (!reservationSnapshot.exists) {
        throw Exception(
          'The product code is not reserved. Please generate a new code.',
        );
      }

      final reservationData = reservationSnapshot.data() ?? {};

      final reservationUserId = reservationData['userId']?.toString();

      final reservationStatus = reservationData['status']?.toString();

      if (reservationUserId != uid) {
        throw Exception(
          'This product code does not belong to the current user.',
        );
      }

      if (reservationStatus != 'reserved') {
        throw Exception('This product code has already been used.');
      }

      transaction.set(productRef, data);

      transaction.update(reservationRef, {
        'status': 'used',
        'productId': productRef.id,
        'usedAt': FieldValue.serverTimestamp(),
      });
    });
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

  /// Updates only the current catalog price of a product.
  /// Existing invoice items keep the price stored on each invoice item.
  Future<void> updateProductPrice({
    required String productId,
    required double price,
  }) async {
    if (!price.isFinite || price < 0) {
      throw Exception('enter_valid_price'.tr());
    }

    final uid = _currentUserId;
    final activeConnectionIds = await _getActiveConnectionIds();
    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? <String, dynamic>{};
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

      // Deliberately update only products/{productId}.price.
      // Invoice documents are not queried or modified here.
      transaction.update(productRef, {'price': price});
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
