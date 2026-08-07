import 'package:flutter/material.dart';

class ProductModel {
  final String name;
  final String code;
  final String price;
  final String quantity;
  final IconData icon;
   final Widget? image;

  ProductModel({
    required this.name,
    required this.code,
    required this.price,
    required this.quantity,
    required this.icon, this.image,
  });
}