import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/main/presentation/widgets/main_nav_item.dart';

class MainMobile extends StatefulWidget {
  const MainMobile({super.key, required this.navItems});

  final List<MainNavItem> navItems;

  @override
  State<MainMobile> createState() => _MainMobileState();
}

class _MainMobileState extends State<MainMobile> {
  int _currentIndex = 0;

  Future<void> _handleBack() async {
    // لو المستخدم مش في Home
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    // لو المستخدم بالفعل في Home
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('exit_app_message'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('exit'.tr()),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _handleBack();
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: IndexedStack(
          // IndexedStack بتحافظ على حالة كل تاب
          // حتى لو المستخدم بدّل تاب ورجع تاني
          index: _currentIndex,
          children: widget.navItems.map((item) => item.screen).toList(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: GNav(
                selectedIndex: _currentIndex,
                onTabChange: (index) {
                  setState(() => _currentIndex = index);
                },
                rippleColor: context.colors.primary.withValues(alpha: 0.1),
                hoverColor: context.colors.primary.withValues(alpha: 0.05),
                gap: 2,
                activeColor: context.colors.primary,
                iconSize: 22.sp,
                tabBackgroundColor: context.colors.primary.withValues(
                  alpha: 0.1,
                ),
                color: context.colors.onSurfaceVariant,
                textStyle: context.text.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                tabs: widget.navItems.map((item) {
                  return GButton(icon: item.icon, text: item.labelKey.tr());
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
