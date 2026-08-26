import 'package:cloud_firestore/cloud_firestore.dart';

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
      customerId: (json['customerId'] as String?) ?? '',
      customerName: (json['customerName'] as String?) ?? '',
      createdAt: _parseCreatedAt(json['createdAt']),
      items: _parseItems(json['items']),
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      total: _parseDouble(json['total']),
      paidAmount: _parseDouble(json['paidAmount']),
      remainingAmount: _parseDouble(json['remainingAmount']),
    );
  }

  static DateTime _parseCreatedAt(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static List<InvoiceItemModel> _parseItems(dynamic value) {
    if (value == null) return <InvoiceItemModel>[];
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => InvoiceItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return <InvoiceItemModel>[];
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
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