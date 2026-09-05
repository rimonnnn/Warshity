import 'invoice_item_model.dart';

class InvoiceModel {
  final String? invoiceId;
  final String customerId;
  final String customerName;
  final String createdAt;

  final List<InvoiceItemModel> items;

  final double subtotal;
  final double discount;
  final double total;
  final double paidAmount;
  final double remainingAmount;

  const InvoiceModel({
    this.invoiceId,
    required this.customerId,
    required this.customerName,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceId: json['invoiceId']?.toString(),
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ??
          json['date']?.toString() ??
          '',
      items: _parseItems(
        json['items'] ?? json['productsItem'],
      ),
      subtotal: _parseDouble(
        json['subtotal'],
      ),
      discount: _parseDouble(
        json['discount'],
      ),
      total: _parseDouble(
        json['total'],
      ),
      paidAmount: _parseDouble(
        json['paidAmount'],
      ),
      remainingAmount: _parseDouble(
        json['remainingAmount'],
      ),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  static List<InvoiceItemModel> _parseItems(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

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
      'createdAt': createdAt,
      'items': items
          .map((item) => item.toJson())
          .toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
    };
  }
}