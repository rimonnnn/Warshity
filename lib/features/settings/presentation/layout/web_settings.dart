import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/theme/cubit/theme_cubit.dart';

import '../widgets/web_settings_category.dart';
import '../widgets/web_settings_sidebar.dart';
import '../widgets/web_settings_language_section.dart';
import '../widgets/web_settings_sharing_section.dart';
import '../widgets/web_settings_store_section.dart';

class WebSettingsScreen extends StatefulWidget {
  const WebSettingsScreen({super.key});

  @override
  State<WebSettingsScreen> createState() => _WebSettingsScreenState();
}

class _WebSettingsScreenState extends State<WebSettingsScreen> {
  int _selectedIndex = 0;

  final List<SettingsCategory> _categories = const [
    SettingsCategory(
      titleKey: 'store_information',
      icon: Icons.store_outlined,
    ),
    SettingsCategory(titleKey: 'share_account', icon: Icons.share_outlined),
    SettingsCategory(titleKey: 'language', icon: Icons.language_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final horizontalPadding = width >= 1500
              ? 40.0
              : width >= 1100
              ? 28.0
              : 20.0;

          final sidebarWidth = width >= 1400
              ? 310.0
              : width >= 1100
              ? 280.0
              : 250.0;

          return Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildMainContent(context, isDark: isDark)),
                const SizedBox(width: 24),
                SizedBox(
                  width: sidebarWidth,
                  child: WebSettingsSidebar(
                    categories: _categories,
                    selectedIndex: _selectedIndex,
                    onSelect: (index) {
                      setState(() => _selectedIndex = index);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, {required bool isDark}) {
    switch (_selectedIndex) {
      case 0:
        return const StoreAndSecuritySection();
      case 1:
        return const AccountSharingSection();
      case 2:
        return LanguageAndThemeSection(isDark: isDark);
      default:
        return const SizedBox.shrink();
    }
  }
}
