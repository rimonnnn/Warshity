import 'package:flutter/material.dart';
import 'package:warshity/features/ClientDetails/data/invoice_model.dart';

class CustomerModel {
  final String name;
  final String phone;
  final String balance;
  final bool hasDebt;
  final Widget? avatar;

  final List<InvoiceModel> invoices;
  final String totalPurchases;
  final String orderCount;

  const CustomerModel({
    required this.name,
    required this.phone,
    required this.balance,
    required this.hasDebt,
    this.avatar,
    this.invoices = const [],
    this.totalPurchases = "0",
    this.orderCount = "0",
  });
}