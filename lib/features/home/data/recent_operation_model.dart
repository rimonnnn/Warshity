import 'package:flutter/material.dart';

class RecentOperationModel {
  final String customerName;
  final String time;
  final String price;
  final Widget? avatar;

  const RecentOperationModel({
    required this.customerName,
    required this.time,
    required this.price,
    this.avatar
  });
}
