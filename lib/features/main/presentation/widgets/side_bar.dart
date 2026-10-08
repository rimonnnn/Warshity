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
    final theme = Theme.of(context);
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 264,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: BorderDirectional(
          end: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.65)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme, colors),

            const SizedBox(height: 28),

            _buildSectionLabel(context, theme),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: navItems.length,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  final isSelected = index == currentIndex;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SidebarTile(
                      icon: isSelected ? item.selectedIcon : item.icon,
                      label: item.labelKey.tr(),
                      isSelected: isSelected,
                      onTap: () => onSelect(index),
                    ),
                  );
                },
              ),
            ),

            _buildFooter(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masiter'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'workspace'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
      child: Text(
        'main_menu'.tr(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: context.colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: colors.onSurfaceVariant),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                'Masiter'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
