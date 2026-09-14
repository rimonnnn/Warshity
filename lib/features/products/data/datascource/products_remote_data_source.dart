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

  Future<String?> _getSharedAccountId() {
    return accountSharingRepository.getSharedAccountId();
  }

  Future<List<String>> _getUserIds() async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    if (sharedAccountId == null || sharedAccountId.isEmpty) {
      return [uid];
    }

    final sharedAccountSnapshot = await firestore
        .collection('shared_accounts')
        .doc(sharedAccountId)
        .get();

    if (!sharedAccountSnapshot.exists) {
      return [uid];
    }

    final data = sharedAccountSnapshot.data() ?? {};
    final members =
        (data['members'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    if (!members.contains(uid)) {
      members.add(uid);
    }

    return members.toSet().toList();
  }

  Stream<List<ProductModel>> watchProducts() {
    final uid = _currentUserId;

    return accountSharingRepository.watchSharedAccountId().asyncExpand((_) {
      final query = firestore
          .collection('products')
          .where('userIds', arrayContains: uid);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc.id, doc.data()))
            .toList();
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
  final sharedAccountId = await _getSharedAccountId();
  final userIds = await _getUserIds();

  final data = product.toFirestore();

  data['userId'] = uid;
  data['userIds'] = userIds;

  final ref = firestore.collection('products').doc();

  data['sharedDataId'] = ref.id;

  if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
    data['sharedAccountId'] = sharedAccountId;
  } else {
    data.remove('sharedAccountId');
  }

  await ref.set(data);
}

  Future<void> deleteProduct(String productId) async {
    final uid = _currentUserId;
    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final userIds = (data['userIds'] as List?)
          ?.map((e) => e.toString())
          .toList();

      final ownerUid = data['userId']?.toString();

      final hasAccess = userIds?.contains(uid) == true || ownerUid == uid;

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      transaction.delete(productRef);
    });
  }

  Future<void> increaseProductQuantity(String productId) async {
    final uid = _currentUserId;
    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final userIds = (data['userIds'] as List?)
          ?.map((e) => e.toString())
          .toList();

      final ownerUid = data['userId']?.toString();

      final hasAccess = userIds?.contains(uid) == true || ownerUid == uid;

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      transaction.update(productRef, {'quantity': FieldValue.increment(1)});
    });
  }

  Future<void> decreaseProductQuantity(String productId) async {
    final uid = _currentUserId;
    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final userIds = (data['userIds'] as List?)
          ?.map((e) => e.toString())
          .toList();

      final ownerUid = data['userId']?.toString();

      final hasAccess = userIds?.contains(uid) == true || ownerUid == uid;

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
    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final userIds = (data['userIds'] as List?)
          ?.map((e) => e.toString())
          .toList();

      final ownerUid = data['userId']?.toString();

      final hasAccess = userIds?.contains(uid) == true || ownerUid == uid;

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      transaction.update(productRef, {'quantity': quantity});
    });
  }
}
