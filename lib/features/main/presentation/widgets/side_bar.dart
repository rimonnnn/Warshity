import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/features/main/presentation/widgets/main_nav_item.dart';
import 'package:warshity/features/main/presentation/widgets/side_bar_tile.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.navItems,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<MainNavItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        border: Border(right: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Image.asset(AppAssets.loginicon, width: 32, height: 32),
                const SizedBox(width: 12),
                Text(
                  'wershity'.tr(),
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ...List.generate(navItems.length, (index) {
            final item = navItems[index];
            final isSelected = index == currentIndex;

            return SidebarTile(
              icon: isSelected ? item.selectedIcon : item.icon,
              label: item.labelKey.tr(),
              isSelected: isSelected,
              onTap: () => onSelect(index),
            );
          }),
          const Spacer(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
