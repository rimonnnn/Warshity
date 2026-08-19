import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/Cleints/presentation/pages/clients_page.dart';
import 'package:warshity/features/home/presentation/layout/mobile_home.dart';
import 'package:warshity/features/home/presentation/layout/web_home.dart';
import 'package:warshity/features/invoices/presentation/layout/invoice_mobile.dart';
import 'package:warshity/features/invoices/presentation/layout/invoice_web.dart';
import 'package:warshity/features/main/presentation/layout/main_mobile.dart';
import 'package:warshity/features/main/presentation/layout/main_web.dart';
import 'package:warshity/features/main/presentation/widgets/main_nav_item.dart';
import 'package:warshity/features/products/presentation/pages/product_pages.dart';
import 'package:warshity/features/settings/presentation/pages/settings_page.dart';

class MainScreen extends StatefulWidget {
  final Locale? locale;

  const MainScreen({
    super.key,
    this.locale,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ============================================================
  // APPLY LOCALE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _changeLocale();
  }

  Future<void> _changeLocale() async {
    if (widget.locale == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      if (context.locale != widget.locale) {
        await context.setLocale(widget.locale!);
      }
    });
  }

  // ============================================================
  // MOBILE NAV ITEMS
  // ============================================================

  static final List<MainNavItem> _mobileNavItems = [
    MainNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      labelKey: 'home',
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
      screen: ProductPages(),
    ),
    MainNavItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      labelKey: 'clients',
      screen: ClientsPage(),
    ),
    MainNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelKey: 'settings',
      screen: SettingsPage(),
    ),
  ];

  // ============================================================
  // WEB NAV ITEMS
  // ============================================================

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
      screen: ProductPages(),
    ),
    MainNavItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      labelKey: 'clients',
      screen: ClientsPage(),
    ),
    MainNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelKey: 'settings',
      screen: SettingsPage(),
    ),
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: MainMobile(
        navItems: _mobileNavItems,
      ),
      desktop: MainWeb(
        navItems: _webNavItems,
      ),
    );
  }
}