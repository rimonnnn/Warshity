/// منطق الصلاحيات لمستندات العملاء والفواتير.
class ClientAccessChecker {
  const ClientAccessChecker._();

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

  /// المالك، أو اتصال مشترك، أو (لو لا يوجد اتصالات مشتركة) userIds القديمة.
  static bool hasAccess({
    required Map<String, dynamic> data,
    required String uid,
    required List<String> activeConnectionIds,
    bool requireActiveConnections = false,
  }) {
    if (data['userId']?.toString() == uid) return true;

    if (requireActiveConnections && activeConnectionIds.isEmpty) {
      return false;
    }

    final sharedConnectionIds = normalizeIds(data['sharedConnectionIds']);

    if (sharedConnectionIds.isNotEmpty) {
      return sharedConnectionIds.any(activeConnectionIds.contains);
    }

    return normalizeIds(data['userIds']).contains(uid);
  }

  /// نسخة متساهلة: تفحص userIds القديمة حتى لو وُجدت اتصالات مشتركة.
  static bool canAccessRecord({
    required Map<String, dynamic> data,
    required String uid,
    required List<String> activeConnectionIds,
  }) {
    if (data['userId']?.toString() == uid) return true;

    final sharedConnectionIds = normalizeIds(data['sharedConnectionIds']);
    if (sharedConnectionIds.any(activeConnectionIds.contains)) return true;

    return normalizeIds(data['userIds']).contains(uid);
  }

  /// المالك أو اتصال مشترك فقط (بدون userIds القديمة).
  static bool hasSharedAccess({
    required Map<String, dynamic> data,
    required String uid,
    required List<String> activeConnectionIds,
  }) {
    if (data['userId']?.toString() == uid) return true;

    return normalizeIds(
      data['sharedConnectionIds'],
    ).any(activeConnectionIds.contains);
  }
}
