import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/theme/cubit/theme_cubit.dart';

class WebSettingsActions extends StatelessWidget {
  const WebSettingsActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'change_language'.tr(),
            onPressed: () {
              final isArabic =
                  context.locale.languageCode == 'ar';

              context.setLocale(
                isArabic
                    ? const Locale('en')
                    : const Locale('ar'),
              );
            },
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_outlined, size: 20),
                const SizedBox(width: 4),
                Text(
                  context.locale.languageCode == 'ar'
                      ? 'EN'
                      : 'AR',
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'change_theme'.tr(),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
            icon: Icon(
              isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}