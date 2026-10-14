import 'package:easy_localization/easy_localization.dart';

/// منطق التحقق من صلاحية الوصول لأي مستند (فاتورة / عميل / منتج).
class InvoiceAccessChecker {
  const InvoiceAccessChecker._();

  static List<String> normalizeIds(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  static bool hasAccess({
    required Map<String, dynamic> data,
    required String uid,
    required List<String> activeConnectionIds,
    bool requireActiveConnections = false,
  }) {
    final ownerUid = data['userId']?.toString();

    if (ownerUid == uid) {
      return true;
    }

    if (requireActiveConnections && activeConnectionIds.isEmpty) {
      return false;
    }

    final sharedConnectionIds = normalizeIds(data['sharedConnectionIds']);

    if (sharedConnectionIds.isNotEmpty) {
      return sharedConnectionIds.any(activeConnectionIds.contains);
    }

    return normalizeIds(data['userIds']).contains(uid);
  }

  /// يرمي Exception بالمفتاح [errorKey] إذا كان المستند بلا مالك
  /// أو لا يملك المستخدم صلاحية الوصول إليه.
  static void ensureAccess({
    required Map<String, dynamic>? data,
    required String uid,
    required List<String> activeConnectionIds,
    required String errorKey,
  }) {
    final ownerUid = data?['userId']?.toString();

    if (data == null || ownerUid == null || ownerUid.isEmpty) {
      throw Exception(errorKey.tr());
    }

    final allowed = hasAccess(
      data: data,
      uid: uid,
      activeConnectionIds: activeConnectionIds,
    );

    if (!allowed) {
      throw Exception(errorKey.tr());
    }
  }
}
