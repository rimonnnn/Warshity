import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/theme/cubit/theme_cubit.dart';

import '../widgets/web_settings_category.dart';
import '../widgets/web_settings_language_section.dart';
import '../widgets/web_settings_sharing_section.dart';
import '../widgets/web_settings_sidebar.dart';
import '../widgets/web_settings_store_section.dart';

class WebSettingsScreen extends StatefulWidget {
  const WebSettingsScreen({super.key});

  @override
  State<WebSettingsScreen> createState() => _WebSettingsScreenState();
}

class _WebSettingsScreenState extends State<WebSettingsScreen> {
  int _selectedIndex = 0;

  final List<SettingsCategory> _categories = const [
    SettingsCategory(titleKey: 'store_information', icon: Icons.store_outlined),
    SettingsCategory(titleKey: 'share_account', icon: Icons.share_outlined),
    SettingsCategory(titleKey: 'language', icon: Icons.language_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    final scheme = context.colors;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // تحت 900px الـ sidebar والمحتوى بيتزاحموا، فالـ sidebar بيتحول لتابات فوق
          final compact = width < 900;

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

          final content = _buildMainContent(context, isDark: isDark);

          // maxWidth: على الشاشات العريضة جدًا المحتوى مايتمطش لآخر الصفحة
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // عنوان الصفحة: كانت من غير أي عنوان
                    Text(
                      'settings1'.tr(),
                      style: context.text.headlineSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (compact) ...[
                      _buildCompactTabs(context),
                      const SizedBox(height: 16),
                      Expanded(child: content),
                    ] else
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // الـ sidebar في البداية (يمين في العربي، شمال في الإنجليزي)
                            // وبعده المحتوى، بدل ما كان في النهاية
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

                            const SizedBox(width: 24),

                            Expanded(child: content),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // تابات أفقية للشاشات الضيقة، بتغيّر نفس الـ _selectedIndex
  Widget _buildCompactTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _categories.length; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: Icon(_categories[i].icon, size: 18),
                label: Text(_categories[i].titleKey.tr()),
                selected: _selectedIndex == i,
                onSelected: (_) => setState(() => _selectedIndex = i),
              ),
            ),
        ],
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
