import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:warshity/features/products/data/models/category_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';

class CategoriesRemoteDataSource {
  final FirebaseFirestore firestore;
  final AccountSharingRepository accountSharingRepository;

  CategoriesRemoteDataSource(this.firestore, this.accountSharingRepository);

  String get _currentUserId {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    return uid;
  }
  Future<List<String>> _getActiveConnectionIds() async {
    return accountSharingRepository.getActiveConnectionIds();
  }

  Stream<List<CategoryModel>> watchCategories() {
    final uid = _currentUserId;

    return accountSharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[];

      streams.add(
        firestore
            .collection('categories')
            .where('userId', isEqualTo: uid)
            .snapshots(),
      );

      for (final connectionId in connectionIds) {
        if (connectionId.isEmpty) {
          continue;
        }

        streams.add(
          firestore
              .collection('categories')
              .where('sharedConnectionIds', arrayContains: connectionId)
              .snapshots(),
        );
      }

      if (streams.length == 1) {
        return streams.first.map((snapshot) {
          final categories = snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc.id, doc.data()))
              .toList();

          categories.sort((a, b) => a.name.compareTo(b.name));

          return categories;
        });
      }

      return Stream.multi((controller) {
        final documents = <String, DocumentSnapshot<Map<String, dynamic>>>{};

        final subscriptions =
            <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

        void emit() {
          final categories = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => CategoryModel.fromFirestore(doc.id, doc.data()!))
              .toList();

          categories.sort((a, b) => a.name.compareTo(b.name));

          controller.add(categories);
        }

        for (final stream in streams) {
          final subscription = stream.listen((snapshot) {
            for (final change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.removed) {
                documents.remove(change.doc.id);
              } else {
                documents[change.doc.id] = change.doc;
              }
            }

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

  Future<void> addCategory(String name) async {
    final uid = _currentUserId;

    final connectionIds = await _getActiveConnectionIds();

    final categoryName = name.trim();

    if (categoryName.isEmpty) {
      throw Exception('category_name_required'.tr());
    }

    final existing = await firestore
        .collection('categories')
        .where('userId', isEqualTo: uid)
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('category_already_exists'.tr());
    }

    final ref = firestore.collection('categories').doc();

    final data = <String, dynamic>{
      'name': categoryName,
      'userId': uid,
      'userIds': [uid],
      'sharedConnectionIds': connectionIds,
      'sharedDataId': ref.id,
    };

    data.remove('sharedAccountId');

    await ref.set(data);
  }
}
