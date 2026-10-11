part of 'account_sharing_remote_data_source.dart';

const int _maxConnections = 5;

const String _connectionIdsField = 'connectionIds';

const String _connectionsCountField = 'connectionsCount';

const String _sharedConnectionIdsField = 'sharedConnectionIds';

const String _inheritedFromConnectionsField = 'inheritedFromConnections';

const List<String> _dataCollections = [
  'clients',
  'products',
  'categories',
  'invoices',
];

/// Shared constants and pure helpers (ids, emails, canonical doc selection).
mixin _AccountSharingCore {
  FirebaseFirestore get firestore;

  FirebaseAuth get auth;

  String get _currentUserId {
    final uid = auth.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    return uid;
  }

  String _normalizeEmail(String value) {
    return value.trim().toLowerCase();
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

  List<String> _extractConnectionIds(Map<String, dynamic> data) {
    final value = data[_connectionIdsField];

    if (value is List) {
      return _normalizeIds(value);
    }

    final legacy = data['sharedAccountId'];

    if (legacy is String && legacy.isNotEmpty) {
      return [legacy];
    }

    if (legacy is List) {
      return _normalizeIds(legacy);
    }

    return <String>[];
  }

  String _getLogicalDataId(Map<String, dynamic> data, String documentId) {
    final sharedDataId = data['sharedDataId']?.toString().trim();

    if (sharedDataId != null && sharedDataId.isNotEmpty) {
      return sharedDataId;
    }

    return documentId;
  }

  String _safeId(String value) {
    final result = value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    if (result.isEmpty) {
      return 'data';
    }

    return result;
  }

  String _getSeparatedDocumentId({
    required String collectionName,
    required String logicalDataId,
    required String uid,
  }) {
    final id = 'separated_${collectionName}_${_safeId(logicalDataId)}_$uid';

    if (id.length <= 1500) {
      return id;
    }

    return id.substring(0, 1500);
  }

  DateTime? _getUpdatedAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  QueryDocumentSnapshot<Map<String, dynamic>> _selectCanonicalDocument({
    required QueryDocumentSnapshot<Map<String, dynamic>> firstDoc,
    required QueryDocumentSnapshot<Map<String, dynamic>> secondDoc,
  }) {
    final firstUpdatedAt = _getUpdatedAt(firstDoc.data()['updatedAt']);

    final secondUpdatedAt = _getUpdatedAt(secondDoc.data()['updatedAt']);

    if (firstUpdatedAt == null && secondUpdatedAt == null) {
      return firstDoc;
    }

    if (firstUpdatedAt == null) {
      return secondDoc;
    }

    if (secondUpdatedAt == null) {
      return firstDoc;
    }

    return firstUpdatedAt.isAfter(secondUpdatedAt) ? firstDoc : secondDoc;
  }

  bool _canShareRecordToConnection({
    required Map<String, dynamic> data,
    required String connectionId,
    required bool hadOtherConnectionsBeforeLink,
  }) {
    if (!hadOtherConnectionsBeforeLink) {
      return true;
    }

    final inherited = _normalizeIds(data[_inheritedFromConnectionsField]);

    if (inherited.isEmpty) {
      return true;
    }

    return inherited.contains(connectionId);
  }
}
