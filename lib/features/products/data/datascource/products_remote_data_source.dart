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

  Stream<List<ProductModel>> watchProducts() {
    final uid = _currentUserId;

    return accountSharingRepository.watchSharedAccountId().asyncExpand((
      sharedAccountId,
    ) {
      Query<Map<String, dynamic>> query = firestore.collection('products');

      if (sharedAccountId == null || sharedAccountId.isEmpty) {
        query = query.where('userId', isEqualTo: uid);
      } else {
        query = query.where('sharedAccountId', isEqualTo: sharedAccountId);
      }

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

    final data = product.toFirestore();

    data['userId'] = uid;

    if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
      data['sharedAccountId'] = sharedAccountId;
    } else {
      data.remove('sharedAccountId');
    }

    await firestore.collection('products').add(data);
  }

  Future<void> deleteProduct(String productId) async {
    final uid = _currentUserId;

    final sharedAccountId = await _getSharedAccountId();

    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      if (ownerUid == null || ownerUid.isEmpty) {
        throw Exception('product_not_found'.tr());
      }

      if (sharedAccountId == null || sharedAccountId.isEmpty) {
        if (ownerUid != uid) {
          throw Exception('product_not_found'.tr());
        }
      } else {
        final documentSharedId = data['sharedAccountId']?.toString();

        if (documentSharedId != sharedAccountId) {
          throw Exception('product_not_found'.tr());
        }
      }

      transaction.delete(productRef);
    });
  }

  Future<void> increaseProductQuantity(String productId) async {
    final productRef = firestore.collection('products').doc(productId);

    await productRef.update({'quantity': FieldValue.increment(1)});
  }

  Future<void> decreaseProductQuantity(String productId) async {
    final productRef = firestore.collection('products').doc(productId);

    await productRef.update({'quantity': FieldValue.increment(-1)});
  }

  Future<void> setProductQuantity({
    required String productId,
    required int quantity,
  }) async {
    if (quantity < 0) {
      throw Exception('quantity_cannot_be_negative'.tr());
    }

    final uid = _currentUserId;

    final sharedAccountId = await _getSharedAccountId();

    final productRef = firestore.collection('products').doc(productId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      if (ownerUid == null || ownerUid.isEmpty) {
        throw Exception('product_not_found'.tr());
      }

      if (sharedAccountId == null || sharedAccountId.isEmpty) {
        if (ownerUid != uid) {
          throw Exception('product_not_found'.tr());
        }
      } else {
        final documentSharedId = data['sharedAccountId']?.toString();

        if (documentSharedId != sharedAccountId) {
          throw Exception('product_not_found'.tr());
        }
      }

      transaction.update(productRef, {'quantity': quantity});
    });
  }
}
