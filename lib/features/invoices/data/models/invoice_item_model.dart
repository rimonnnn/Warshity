class InvoiceItemModel {
  final String productName;
  final int quantity;
  final double price;

  InvoiceItemModel({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}