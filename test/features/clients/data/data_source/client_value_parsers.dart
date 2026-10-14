import 'package:cloud_firestore/cloud_firestore.dart';

/// دوال تحويل القيم القادمة من مستندات الفواتير.
class ClientValueParsers {
  const ClientValueParsers._();

  static double doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static double normalizedPaidAmount(Map<String, dynamic> data, double total) {
    final rawPaid = data['paidAmount'];
    final rawRemaining = data['remainingAmount'];

    final parsedPaid = rawPaid is num
        ? rawPaid.toDouble()
        : double.tryParse(rawPaid?.toString() ?? '');
    final parsedRemaining = rawRemaining is num
        ? rawRemaining.toDouble()
        : double.tryParse(rawRemaining?.toString() ?? '');

    final paid =
        parsedPaid ?? (parsedRemaining != null ? total - parsedRemaining : 0.0);

    return paid.clamp(0.0, total).toDouble();
  }

  static DateTime invoiceDate(Map<String, dynamic> data) {
    final rawDate = data['createdAt'] ?? data['date'];
    if (rawDate is Timestamp) return rawDate.toDate();

    final value = rawDate?.toString().trim() ?? '';
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;

    final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(value);
    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '') ?? 1;
      final month = int.tryParse(match.group(2) ?? '') ?? 1;
      final year = int.tryParse(match.group(3) ?? '') ?? 1970;
      try {
        return DateTime(year, month, day);
      } catch (_) {}
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
