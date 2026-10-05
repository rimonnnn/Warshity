import 'package:flutter/material.dart';

class QuickActionModel {
  const QuickActionModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
}