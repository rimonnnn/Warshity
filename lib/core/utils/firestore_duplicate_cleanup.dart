import 'package:cloud_firestore/cloud_firestore.dart';

class DuplicateCleanupResult {
  final int totalInspected;
  final int confirmedDuplicates;
  final int ambiguousCases;
  final int willBeDeleted;
  final List<DuplicateGroup> groups;

  const DuplicateCleanupResult({
    required this.totalInspected,
    required this.confirmedDuplicates,
    required this.ambiguousCases,
    required this.willBeDeleted,
    required this.groups,
  });
}

class DuplicateGroup {
  final String collection;
  final String logicalKey;
  final DuplicateDocument canonical;
  final List<DuplicateDocument> duplicates;
  final String reason;

  const DuplicateGroup({
    required this.collection,
    required this.logicalKey,
    required this.canonical,
    required this.duplicates,
    required this.reason,
  });
}

class DuplicateDocument {
  final String id;
  final String userId;
  final Map<String, dynamic> data;
  final bool isReferenced;

  const DuplicateDocument({
    required this.id,
    required this.userId,
    required this.data,
    required this.isReferenced,
  });
}

class FirestoreDuplicateCleanup {
  FirestoreDuplicateCleanup(this.firestore);

  final FirebaseFirestore firestore;

  static const _collections = ['products', 'clients', 'categories', 'invoices'];

  Future<DuplicateCleanupResult> discoverDuplicates() async {
    int totalInspected = 0;
    int confirmedDuplicates = 0;
    int ambiguousCases = 0;
    int willBeDeleted = 0;
    final allGroups = <DuplicateGroup>[];

    for (final collectionName in _collections) {
      final result = await _discoverCollectionDuplicates(collectionName);
      totalInspected += result.totalInspected;
      confirmedDuplicates += result.confirmedDuplicates;
      ambiguousCases += result.ambiguousCases;
      willBeDeleted += result.willBeDeleted;
      allGroups.addAll(result.groups);
    }

    return DuplicateCleanupResult(
      totalInspected: totalInspected,
      confirmedDuplicates: confirmedDuplicates,
      ambiguousCases: ambiguousCases,
      willBeDeleted: willBeDeleted,
      groups: allGroups,
    );
  }

  Future<_CollectionResult> _discoverCollectionDuplicates(
    String collectionName,
  ) async {
    final docs = await _fetchAllDocs(collectionName);

    if (docs.isEmpty) {
      return const _CollectionResult(
        totalInspected: 0,
        confirmedDuplicates: 0,
        ambiguousCases: 0,
        willBeDeleted: 0,
        groups: [],
      );
    }

    final logicalKeys = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    for (final doc in docs) {
      final key = _computeLogicalKey(collectionName, doc.data());
      logicalKeys.putIfAbsent(key, () => []).add(doc);
    }

    final referencedIds = await _findReferencedIds();

    final groups = <DuplicateGroup>[];
    int confirmedDuplicates = 0;
    int ambiguousCases = 0;
    int willBeDeleted = 0;

    for (final entry in logicalKeys.entries) {
      if (entry.value.length < 2) continue;

      final groupDocs = entry.value;
      final uniqueUserIds = groupDocs
          .map((d) => d.data()['userId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      if (uniqueUserIds.length < 2) continue;

      final canonical = _pickCanonical(groupDocs, referencedIds);

      final duplicates = <DuplicateDocument>[];

      for (final doc in groupDocs) {
        if (doc.id == canonical.id) continue;

        duplicates.add(DuplicateDocument(
          id: doc.id,
          userId: doc.data()['userId']?.toString() ?? '',
          data: doc.data(),
          isReferenced: referencedIds.contains(doc.id),
        ));
      }

      if (duplicates.isEmpty) continue;

      final unreferencedDuplicates = duplicates.where((d) => !d.isReferenced).toList();
      final referencedDuplicates = duplicates.where((d) => d.isReferenced).toList();

      if (referencedDuplicates.isNotEmpty) {
        ambiguousCases += referencedDuplicates.length;
      }

      willBeDeleted += unreferencedDuplicates.length;
      confirmedDuplicates += unreferencedDuplicates.length;

      groups.add(DuplicateGroup(
        collection: collectionName,
        logicalKey: entry.key,
        canonical: DuplicateDocument(
          id: canonical.id,
          userId: canonical.data()['userId']?.toString() ?? '',
          data: canonical.data(),
          isReferenced: referencedIds.contains(canonical.id),
        ),
        duplicates: duplicates,
        reason: _buildReason(collectionName, canonical, duplicates, referencedIds),
      ));
    }

    return _CollectionResult(
      totalInspected: docs.length,
      confirmedDuplicates: confirmedDuplicates,
      ambiguousCases: ambiguousCases,
      willBeDeleted: willBeDeleted,
      groups: groups,
    );
  }

  String _computeLogicalKey(String collection, Map<String, dynamic> data) {
    switch (collection) {
      case 'products':
        return _productKey(data);
      case 'clients':
        return _clientKey(data);
      case 'categories':
        return _categoryKey(data);
      case 'invoices':
        return _invoiceKey(data);
      default:
        return '';
    }
  }

  String _productKey(Map<String, dynamic> d) {
    final name = (d['name']?.toString() ?? '').trim().toLowerCase();
    final barcode = (d['barcode']?.toString() ?? '').trim().toLowerCase();
    final category = (d['category']?.toString() ?? '').trim().toLowerCase();
    final price = d['price']?.toString() ?? '0';
    final unit = (d['unit']?.toString() ?? '').trim().toLowerCase();
    final imageUrl = (d['imageurl']?.toString() ?? d['imageUrl']?.toString() ?? '').trim().toLowerCase();
    final quantity = d['quantity']?.toString() ?? '0';

    return '$name|$barcode|$category|$price|$unit|$imageUrl|$quantity';
  }

  String _clientKey(Map<String, dynamic> d) {
    final name = (d['name']?.toString() ?? '').trim().toLowerCase();
    final phone = (d['phone']?.toString() ?? '').trim().toLowerCase();
    final address = (d['address']?.toString() ?? '').trim().toLowerCase();
    final balance = d['balance']?.toString() ?? '0';
    final hasDebt = d['hasDebt']?.toString() ?? 'false';
    final totalPurchases = d['totalPurchases']?.toString() ?? '0';
    final orderCount = d['orderCount']?.toString() ?? '0';

    return '$name|$phone|$address|$balance|$hasDebt|$totalPurchases|$orderCount';
  }

  String _categoryKey(Map<String, dynamic> d) {
    return (d['name']?.toString() ?? '').trim().toLowerCase();
  }

  String _invoiceKey(Map<String, dynamic> d) {
    final customerName = (d['customerName']?.toString() ?? '').trim().toLowerCase();
    final total = d['total']?.toString() ?? '0';
    final subtotal = d['subtotal']?.toString() ?? '0';
    final discount = d['discount']?.toString() ?? '0';
    final paidAmount = d['paidAmount']?.toString() ?? '0';
    final remainingAmount = d['remainingAmount']?.toString() ?? '0';
    final stockDeducted = d['stockDeducted']?.toString() ?? 'false';
    final createdAt = (d['createdAt']?.toString() ?? '').trim();

    final items = d['items'];
    String itemsHash = '';
    if (items is List) {
      final itemParts = items.map((item) {
        if (item is! Map) return '';
        final productName = (item['productName']?.toString() ?? '').trim().toLowerCase();
        final quantity = item['quantity']?.toString() ?? '0';
        final unitPrice = item['unitPrice']?.toString() ?? '0';
        return '$productName:$quantity:$unitPrice';
      }).where((s) => s.isNotEmpty).toList();
      itemsHash = itemParts.join(';');
    }

    return '$customerName|$total|$subtotal|$discount|$paidAmount|$remainingAmount|$stockDeducted|$createdAt|$itemsHash';
  }

  QueryDocumentSnapshot<Map<String, dynamic>> _pickCanonical(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    Set<String> referencedIds,
  ) {
    final referenced = docs.where((d) => referencedIds.contains(d.id)).toList();

    if (referenced.length == 1) return referenced.first;
    if (referenced.length > 1) return referenced.first;

    return docs.first;
  }

  String _buildReason(
    String collection,
    QueryDocumentSnapshot<Map<String, dynamic>> canonical,
    List<DuplicateDocument> duplicates,
    Set<String> referencedIds,
  ) {
    final parts = <String>[];

    parts.add('Same logical $collection data');

    if (duplicates.any((d) => d.isReferenced)) {
      parts.add('WARNING: some duplicates are referenced by invoices');
    }

    final canonicalUserId = canonical.data()['userId']?.toString() ?? '';
    final dupUserIds = duplicates.map((d) => d.userId).toSet();

    if (dupUserIds.contains(canonicalUserId)) {
      parts.add('same owner');
    } else {
      parts.add('different owners (canonical: $canonicalUserId, dups: ${dupUserIds.join(",")})');
    }

    return parts.join('. ');
  }

  Future<Set<String>> _findReferencedIds() async {
    final referenced = <String>{};

    final invoiceSnapshot = await firestore.collection('invoices').get();

    for (final doc in invoiceSnapshot.docs) {
      final data = doc.data();

      final customerId = data['customerId']?.toString();
      if (customerId != null && customerId.isNotEmpty) {
        referenced.add(customerId);
      }

      final items = data['items'];
      if (items is List) {
        for (final item in items) {
          if (item is! Map) continue;
          final productId = item['productId']?.toString();
          if (productId != null && productId.isNotEmpty) {
            referenced.add(productId);
          }
        }
      }
    }

    return referenced;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchAllDocs(
    String collectionName,
  ) async {
    final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    DocumentSnapshot<Map<String, dynamic>>? lastDoc;

    while (true) {
      Query<Map<String, dynamic>> query = firestore
          .collection(collectionName)
          .limit(400);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) break;

      allDocs.addAll(snapshot.docs);
      lastDoc = snapshot.docs.last;

      if (snapshot.docs.length < 400) break;
    }

    return allDocs;
  }

  Future<int> executeCleanup(DuplicateCleanupResult result) async {
    int totalDeleted = 0;

    for (final group in result.groups) {
      for (final dup in group.duplicates) {
        if (dup.isReferenced) continue;

        try {
          await firestore.collection(group.collection).doc(dup.id).delete();
          totalDeleted++;
        } catch (e) {
          // skip on error
        }
      }
    }

    return totalDeleted;
  }
}

class _CollectionResult {
  final int totalInspected;
  final int confirmedDuplicates;
  final int ambiguousCases;
  final int willBeDeleted;
  final List<DuplicateGroup> groups;

  const _CollectionResult({
    required this.totalInspected,
    required this.confirmedDuplicates,
    required this.ambiguousCases,
    required this.willBeDeleted,
    required this.groups,
  });
}
