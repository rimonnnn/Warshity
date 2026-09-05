import 'package:warshity/features/ClientDetails/data/invoice_model.dart';

class CustomerModel {
  final String? id;
  final String? name;
  final String? phone;
  final String? address;
  final num? balance;
  final bool? hasDebt;

  final List<InvoiceClientsModel> invoices;
  final num totalPurchases;
  final num orderCount;

  const CustomerModel({
    this.id,
     this.name,
     this.phone,
     this.address,
     this.balance,
     this.hasDebt,

    this.invoices = const [],
    this.totalPurchases = 0,
    this.orderCount = 0,
  });
  factory CustomerModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CustomerModel(
      id: id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      balance: (data['balance'] as num?)?.toInt() ?? 0,
      hasDebt: data['hasDebt'] as bool? ?? false,
      totalPurchases: (data['totalPurchases'] as num?)?.toInt() ?? 0,
      orderCount: (data['orderCount'] as num?)?.toInt() ?? 0,
      address: data['address'] as String? ?? '',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'balance': balance,
      'address': address,
      'hasDebt': hasDebt,
      'totalPurchases': totalPurchases,
      'orderCount': orderCount,
    };
  }
}
