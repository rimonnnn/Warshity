import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:warshity/features/products/data/models/category_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';

class CategoriesRemoteDataSource {
  final FirebaseFirestore firestore;

  CategoriesRemoteDataSource(this.firestore);

  String get _currentUserId {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    return uid;
  }

  Future<String?> _getSharedAccountId() async {
    return GetIt.I<AccountSharingRepository>().getSharedAccountId();
  }

  Stream<List<CategoryModel>> watchCategories() {
    final uid = _currentUserId;

    return GetIt.I<AccountSharingRepository>()
        .watchSharedAccountId()
        .asyncExpand((sharedAccountId) {
      Query<Map<String, dynamic>> query = firestore.collection('categories');

      if (sharedAccountId == null || sharedAccountId.isEmpty) {
        query = query.where('userId', isEqualTo: uid);
      } else {
        query = query.where(
          'sharedAccountId',
          isEqualTo: sharedAccountId,
        );
      }

      return query.snapshots().map((snapshot) {
        final categories = snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc.id, doc.data()))
            .toList();

        categories.sort((a, b) => a.name.compareTo(b.name));

        return categories;
      });
    });
  }

  Future<void> addCategory(String name) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final categoryName = name.trim();

    if (categoryName.isEmpty) {
      throw Exception('category_name_required'.tr());
    }

    Query<Map<String, dynamic>> query = firestore.collection('categories');

    if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
      query = query.where(
        'sharedAccountId',
        isEqualTo: sharedAccountId,
      );
    } else {
      query = query.where('userId', isEqualTo: uid);
    }

    final existing = await query
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('category_already_exists'.tr());
    }

    final data = <String, dynamic>{'name': categoryName, 'userId': uid};

    if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
      data['sharedAccountId'] = sharedAccountId;
    }

    await firestore.collection('categories').add(data);
  }
}
