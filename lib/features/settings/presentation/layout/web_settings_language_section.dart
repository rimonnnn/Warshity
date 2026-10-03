import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/theme/cubit/theme_cubit.dart';

import 'web_settings_rows.dart';
import 'web_settings_shared_widgets.dart';

class LanguageAndThemeSection extends StatelessWidget {
  final bool isDark;

  const LanguageAndThemeSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish =
        context.locale.languageCode == 'en';

    final themeIcon = isDark
        ? Icons.dark_mode_outlined
        : Icons.light_mode_outlined;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          SettingsPageHeader(
            title: 'language'.tr(),
            subtitle: 'theme'.tr(),
            icon: isDark
                ? Icons.dark_mode_outlined
                : Icons.language_outlined,
          ),

          const SizedBox(height: 20),

          SettingsContentCard(
            title: 'language'.tr(),
            icon: Icons.language_outlined,
            child: SettingsRow(
              icon: Icons.language_outlined,
              title: 'language'.tr(),
              trailing: TextButton(
                onPressed: () {
                  final newLocale = isEnglish
                      ? const Locale('ar')
                      : const Locale('en');

                  context.push(
                    AppRoutes.splashScreen,
                    extra: newLocale,
                  );
                },
                child: Text(
                  isEnglish
                      ? 'English'
                      : 'العربية',
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SettingsContentCard(
            title: 'theme'.tr(),
            icon: themeIcon,
            child: SettingsRow(
              icon: themeIcon,
              title: 'theme'.tr(),
              trailing: IconButton(
                onPressed: () {
                  context
                      .read<ThemeCubit>()
                      .toggleTheme();
                },
                icon: Icon(
                  themeIcon,
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}