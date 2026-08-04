import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/home/presentation/screens/home_screen.dart';
import 'package:warshity/features/main/presentation/layout/main_mobile.dart';
import 'package:warshity/features/main/presentation/layout/main_web.dart';
import 'package:warshity/features/main/presentation/widgets/main_nav_item.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // قايمة الـ tabs معرّفة مرة واحدة هنا، وبتتمرر لكل من الموبايل والويب
  // عشان لو ضفت/شلت تاب، تعدّل مكان واحد بس
  static final List<MainNavItem> _navItems = [
    MainNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      labelKey: 'home'.tr(),
      screen: const HomeScreen(),
    ),
    MainNavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      labelKey: 'invoices'.tr(),
      screen: const Center(child: Text('Invoices')), // TODO: استبدلها
    ),
    MainNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelKey: 'settings'.tr(),
      screen: const Center(child: Text('Settings')), // TODO: استبدلها
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: MainMobile(navItems: _navItems),
      desktop: MainWeb(navItems: _navItems),
    );
  }
}
