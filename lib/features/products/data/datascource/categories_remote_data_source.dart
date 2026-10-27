import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:warshity/core/errors/app_failure.dart';
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
          final categories = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => CategoryModel.fromFirestore(doc.id, doc.data()!))
              .toList();

          categories.sort((a, b) => a.name.compareTo(b.name));

          controller.add(categories);
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
