import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';

import 'web_settings_category.dart';
import 'web_settings_logout_button.dart';

class WebSettingsSidebar extends StatelessWidget {
  final List<SettingsCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const WebSettingsSidebar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, theme),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    'settings1'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...List.generate(categories.length, (index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SidebarCategory(
                      title: category.titleKey.tr(),
                      icon: category.icon,
                      selected: selectedIndex == index,
                      onTap: () => onSelect(index),
                    ),
                  );
                }),
              ],
            ),
          ),
          _buildBottomSection(context, theme, colors),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings1'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Manage your preferences'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Column(
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: _buildAppInfo(context, theme),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          child: const LogoutButton(),
        ),
      ],
    );
  }

  Widget _buildAppInfo(BuildContext context, ThemeData theme) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'masiter'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
              // min: من غيرها الـ Row بياخد العرض كله والـ pill بيتمط
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'version'.tr(),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "1.0.0",
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
