import 'package:flutter/material.dart';

class ProductControllers {
  final name = TextEditingController();
  final barcode = TextEditingController();
  final price = TextEditingController();
  final quantity = TextEditingController();

  void dispose() {
    name.dispose();
    barcode.dispose();
    price.dispose();
    quantity.dispose();
  }
}