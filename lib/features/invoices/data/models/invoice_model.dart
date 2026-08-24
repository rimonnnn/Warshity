import 'invoice_item_model.dart';

class InvoiceModel {
  final String invoiceId;
  final String? customerId;
  final String customerName;
  final String date;
  final double totalPrice;
  final List<InvoiceItemModel> productsItem;
  final double debt;

  InvoiceModel({
    required this.invoiceId,
    this.customerId,
    required this.customerName,
    required this.date,
    required this.totalPrice,
    required this.productsItem,
    required this.debt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceId: json['invoiceId'] as String,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String,
      date: json['date'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      productsItem: (json['productsItem'] as List)
          .map(
            (item) => InvoiceItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      debt: (json['debt'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'customerId': customerId,
      'customerName': customerName,
      'date': date,
      'totalPrice': totalPrice,
      'productsItem': productsItem
          .map((item) => item.toJson())
          .toList(),
      'debt': debt,
    };
  }
}