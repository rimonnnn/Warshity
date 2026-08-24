import 'invoice_item_model.dart';

class InvoiceModel {
  final String? invoiceId;

  final String customerId;
  final String customerName;

  final DateTime createdAt;

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
      invoiceId: json['invoiceId'] as String?,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List)
          .map(
            (item) => InvoiceItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'customerId': customerId,
      'customerName': customerName,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
    };
  }
}