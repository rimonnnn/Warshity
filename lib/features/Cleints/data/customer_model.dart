import 'package:flutter/material.dart';

class CustomerModel {
  final String name;
  final String phone;
  final String balance;
  final bool hasDebt;
  final Widget? avatar;

  const CustomerModel({
    required this.name,
    required this.phone,
    required this.balance,
    required this.hasDebt,
    this.avatar,
  });
}