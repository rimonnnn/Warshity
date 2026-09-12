import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/Cleints/presentation/pages/clients_page.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';
import 'package:warshity/features/home/presentation/layout/web_home.dart';
import 'package:warshity/features/home/presentation/pages/home_page.dart';
import 'package:warshity/features/invoices/presentation/layout/invoice_web.dart';
import 'package:warshity/features/invoices/presentation/pages/invoice_pages.dart';
import 'package:warshity/features/main/presentation/layout/main_mobile.dart';
import 'package:warshity/features/main/presentation/layout/main_web.dart';
import 'package:warshity/features/main/presentation/widgets/main_nav_item.dart';
import 'package:warshity/features/products/presentation/pages/product_pages.dart';
import 'package:warshity/features/settings/presentation/pages/settings_page.dart';

class MainScreen extends StatefulWidget {
  final Locale? locale;

  const MainScreen({super.key, this.locale});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  static final List<MainNavItem> _mobileNavItems = [
    MainNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      labelKey: 'home',
      screen: HomePage(),
    ),
    MainNavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      labelKey: 'invoices',
      screen: const InvoicePages(),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AccountSharingCubit>(),
      child: Builder(
        builder: (context) {
          return BlocListener<AccountSharingCubit, AccountSharingState>(
            listener: (context, state) async {
              if (state is AccountInvitationAcceptedRemotely) {
                showAnimatedSnackDialog(
                  context,
                  message: 'invitation_accepted'.tr(),
                  type: AnimatedSnackBarType.success,
                );
                await Future.delayed(const Duration(seconds: 2));
                if (!context.mounted) return;
                context.goNamed(AppRoutes.splashScreen);
              }

              if (state is AccountInvitationRejectedRemotely) {
                showAnimatedSnackDialog(
                  context,
                  message: 'invitation_rejected'.tr(),
                  type: AnimatedSnackBarType.error,
                );
              }

              if (state is AccountSharedAccountDeletedRemotely) {
                showAnimatedSnackDialog(
                  context,
                  message: 'shared_account_deleted'.tr(),
                  type: AnimatedSnackBarType.error,
                );
                await Future.delayed(const Duration(seconds: 2));
                if (!context.mounted) return;
                context.goNamed(AppRoutes.splashScreen);
              }
            },
            child: AppResponsive(
              mobile: MainMobile(navItems: _mobileNavItems),
              desktop: MainWeb(navItems: _webNavItems),
            ),
          );
        },
      ),
    );
  }
}
