import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: IndexedStack(
        // IndexedStack بتحافظ على حالة كل تاب (scroll position, form input, إلخ)
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
              tabBackgroundColor: context.colors.primary.withValues(alpha: 0.1),
              color: context.colors.onSurfaceVariant,
              textStyle: context.text.labelMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              tabs: widget.navItems.map((item) {
                return GButton(icon: item.icon, text: item.labelKey.tr());
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
