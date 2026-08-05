import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/home/presentation/layout/mobile_home.dart';
import 'package:warshity/features/home/presentation/layout/web_home.dart';
import 'package:warshity/features/invoices/presentation/layout/invoice_mobile.dart';
import 'package:warshity/features/invoices/presentation/layout/invoice_web.dart';
import 'package:warshity/features/main/presentation/layout/main_mobile.dart';
import 'package:warshity/features/main/presentation/layout/main_web.dart';
import 'package:warshity/features/main/presentation/widgets/main_nav_item.dart';
import 'package:warshity/features/settings/presentation/layout/mobile_settings.dart';
import 'package:warshity/features/settings/presentation/layout/web_settings.dart';
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // نسخة الموبايل: كل تاب بياخد الـ layout بتاعه المخصص للموبايل مباشرة
  // من غير أي AppResponsive جوه أي تاب — القرار اتاخد هنا مرة واحدة بس
  static final List<MainNavItem> _mobileNavItems = [
    MainNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      labelKey: 'home', // مفتاح خام، من غير .tr() هنا
      screen: const MobileHome(),
    ),
    MainNavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      labelKey: 'invoices',
      screen: const InvoiceMobile(),
    ),
    MainNavItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      labelKey: 'products',
      screen: const Center(child: Text('Products')), // TODO: استبدلها
    ),
    MainNavItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      labelKey: 'clients',
      screen: const Center(child: Text('Clients')), // TODO: استبدلها
    ),
    MainNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelKey: 'settings',
      screen: MobileSettingsScreen()
    ),
  ];

  // نسخة الويب: نفس التابات، بس كل واحد بياخد الـ layout بتاعه المخصص للويب
  static final List<MainNavItem> _webNavItems = [
    MainNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      labelKey: 'home',
      screen: WebHome(),
    ),
    MainNavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      labelKey: 'invoices',
      screen: const InvoiceWeb(),
    ),
    MainNavItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      labelKey: 'products',
      screen: const Center(child: Text('Products')), // TODO: استبدلها
    ),
    MainNavItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      labelKey: 'clients',
      screen: const Center(child: Text('Clients')), // TODO: استبدلها
    ),
    MainNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelKey: 'settings',
      screen: WebSettingsScreen(), // TODO: استبدلها
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: MainMobile(navItems: _mobileNavItems),
      desktop: MainWeb(navItems: _webNavItems),
    );
  }
}
