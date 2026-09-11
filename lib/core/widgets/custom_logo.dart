import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({
    super.key,
    required this.width,
    required this.height,
    required this.logoPath,
  });
  final double width;
  final double height;

  final String logoPath;
  @override
  Widget build(BuildContext context) {
    return Image.asset(logoPath, width: width , height: height);
  }
}
