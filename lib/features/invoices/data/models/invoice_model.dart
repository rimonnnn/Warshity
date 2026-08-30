import 'invoice_item_model.dart';

class InvoiceModel {
  final String? invoiceId;
  final String customerId;
  final String customerName;
  final DateTime createdAt;
  final List<InvoiceItemModel> items;
  final double total;
  final double debt;

  const InvoiceModel({
    this.invoiceId,
    required this.customerId,
    required this.customerName,
    required this.createdAt,
    required this.items,
    required this.total,
    required this.debt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceId: json['invoiceId']?.toString(),
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      createdAt: _parseDate(json['date']),
      items: _parseItems(json['productsItem']),
      total: _parseDouble(json['totalPrice']),
      debt: _parseDouble(json['debt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;

    if (value != null) {
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<InvoiceItemModel> _parseItems(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map(
          (item) => InvoiceItemModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'customerId': customerId,
      'customerName': customerName,
      'date': createdAt.toIso8601String(),
      'productsItem': items.map((item) => item.toJson()).toList(),
      'totalPrice': total,
      'debt': debt,
    };
  }
}