import 'invoice_item_model.dart';

class InvoiceModel {
  final String invoiceId;
  final String customerName;
  final String date;
  final double totalPrice;
  final List<InvoiceItemModel> productsItem;
  final double debt;
  final double balance;

  InvoiceModel({
    required this.invoiceId,
    required this.customerName,
    required this.date,
    required this.totalPrice,
    required this.productsItem,
    required this.debt,
    required this.balance,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceId: json['invoiceId'] as String,
      customerName: json['customerName'] as String,
      date: json['date'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      productsItem: (json['productsItem'] as List)
          .map((item) => InvoiceItemModel.fromJson(item))
          .toList(),
      debt: (json['debt'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'customerName': customerName,
      'date': date,
      'totalPrice': totalPrice,
      'productsItem': productsItem.map((item) => item.toJson()).toList(),
      'debt': debt,
      'balance': balance,
    };
  }
}