class InvoiceItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  InvoiceItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}