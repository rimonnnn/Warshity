class ProductModel {
  final String id;
  final String name;
  final String barcode;
  final String category;
  final double price;
  final int quantity;
  final String unit;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
  });

  factory ProductModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProductModel(
      id: id,
      name: data['name']?.toString() ?? '',
      barcode: data['barcode']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unit: data['unit']?.toString() ?? '',
      imageUrl: data['imageurl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'barcode': barcode,
      'category': category,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imageurl': imageUrl,
    };
  }
}