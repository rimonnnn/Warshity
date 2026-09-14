import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMigration {
  FirestoreMigration(this.firestore);

  final FirebaseFirestore firestore;

  final Map<String, List<String>> _membersCache = {};

  Future<MigrationResult> migrateAllDocuments() async {
    int totalProcessed = 0;
    int totalSkipped = 0;
    int totalErrors = 0;

    final collections = ['clients', 'products', 'categories', 'invoices'];

    for (final collectionName in collections) {
      final result = await _migrateCollection(collectionName);
      totalProcessed += result.processed;
      totalSkipped += result.skipped;
      totalErrors += result.errors;
    }

    return MigrationResult(
      processed: totalProcessed,
      skipped: totalSkipped,
      errors: totalErrors,
    );
  }

  Future<CollectionMigrationResult> _migrateCollection(
    String collectionName,
  ) async {
    int processed = 0;
    int skipped = 0;
    int errors = 0;

    QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;
    const batchSize = 400;

    while (true) {
      Query<Map<String, dynamic>> query = firestore
          .collection(collectionName)
          .limit(batchSize);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = firestore.batch();
      int batchOps = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userIds = data['userIds'];

        if (userIds is List && userIds.isNotEmpty) {
          skipped++;
          continue;
        }

        final userId = data['userId']?.toString();
        final sharedAccountId = data['sharedAccountId']?.toString();

        List<String> newUserIds;

        if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
          newUserIds = await _getMembersFromSharedAccount(sharedAccountId);
        } else if (userId != null && userId.isNotEmpty) {
          newUserIds = [userId];
        } else {
          errors++;
          continue;
        }

        if (newUserIds.isEmpty) {
          errors++;
          continue;
        }

        batch.update(doc.reference, {
          'userIds': newUserIds,
        });

        batchOps++;
        processed++;
      }

      if (batchOps > 0) {
        try {
          await batch.commit();
        } catch (e) {
          errors += batchOps;
        }
      }

      lastDoc = snapshot.docs.last;

      if (snapshot.docs.length < batchSize) {
        break;
      }
    }

    return CollectionMigrationResult(
      processed: processed,
      skipped: skipped,
      errors: errors,
    );
  }

  Future<List<String>> _getMembersFromSharedAccount(
    String sharedAccountId,
  ) async {
    if (_membersCache.containsKey(sharedAccountId)) {
      return _membersCache[sharedAccountId]!;
    }

    final snapshot = await firestore
        .collection('shared_accounts')
        .doc(sharedAccountId)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      _membersCache[sharedAccountId] = [];
      return [];
    }

    final data = snapshot.data()!;
    final members = data['members'];

    if (members is! List) {
      _membersCache[sharedAccountId] = [];
      return [];
    }

    final result = members
        .map((e) => e.toString())
        .where((id) => id.isNotEmpty)
        .toList();

    _membersCache[sharedAccountId] = result;
    return result;
  }
}

class MigrationResult {
  final int processed;
  final int skipped;
  final int errors;

  const MigrationResult({
    required this.processed,
    required this.skipped,
    required this.errors,
  });

  @override
  String toString() =>
      'MigrationResult(processed: $processed, skipped: $skipped, errors: $errors)';
}

class CollectionMigrationResult {
  final int processed;
  final int skipped;
  final int errors;

  const CollectionMigrationResult({
    required this.processed,
    required this.skipped,
    required this.errors,
  });
}
