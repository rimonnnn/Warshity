import 'package:flutter/material.dart';

/// تعريف موحّد لعناصر التنقل الرئيسية، مستخدم في الموبايل (BottomNavigationBar)
/// والويب (Sidebar) عشان نتجنب تكرار نفس البيانات مرتين.
class MainNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String labelKey;
  final Widget screen;

  const MainNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
    required this.screen,
  });
}
