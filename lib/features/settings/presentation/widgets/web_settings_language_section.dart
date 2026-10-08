import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/theme/cubit/theme_cubit.dart';

import 'web_settings_rows.dart';
import 'web_settings_shared_widgets.dart';

class LanguageAndThemeSection extends StatelessWidget {
  final bool isDark;
  const LanguageAndThemeSection({super.key, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final theme = Theme.of(context);
    final languageCode = context.locale.languageCode;
    final isEnglish = languageCode == 'en';
    final themeIcon = isDark
        ? Icons.dark_mode_outlined
        : Icons.light_mode_outlined;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsPageHeader(
                title: 'language_and_appearance'.tr(),
                subtitle: 'language_and_appearance_description'.tr(),
                icon: Icons.tune_outlined,
              ),
              const SizedBox(height: 28),
              SettingsContentCard(
                title: 'preferences'.tr(),
                icon: Icons.settings_outlined,
                child: Column(
                  children: [
                    _buildLanguageRow(
                      context: context,
                      theme: theme,
                      scheme: scheme,
                      isEnglish: isEnglish,
                    ),
                    const SizedBox(height: 4),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: 4),
                    _buildThemeRow(
                      context: context,
                      theme: theme,
                      scheme: scheme,
                      isDark: isDark,
                      themeIcon: themeIcon,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageRow({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme scheme,
    required bool isEnglish,
  }) {
    return SettingsRow(
      icon: Icons.language_outlined,
      title: 'language'.tr(),
      trailing: SegmentedButton<String>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          foregroundColor: scheme.onSurfaceVariant,
          selectedForegroundColor: scheme.primary,
          selectedBackgroundColor: scheme.primaryContainer,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        segments: const [
          ButtonSegment(value: 'en', label: Text('English')),
          ButtonSegment(value: 'ar', label: Text('العربية')),
        ],
        selected: {isEnglish ? 'en' : 'ar'},
        onSelectionChanged: (selection) async {
          final code = selection.first;
          if (code == context.locale.languageCode) {
            return;
          }
          await context.setLocale(Locale(code));
        },
      ),
    );
  }

  Widget _buildThemeRow({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme scheme,
    required bool isDark,
    required IconData themeIcon,
  }) {
    return SettingsRow(
      icon: themeIcon,
      title: 'theme'.tr(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isDark ? 'dark'.tr() : 'light'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: isDark,
            onChanged: (_) {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}
