import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/settings/presentation/layout/mobile_settings.dart';
import 'package:warshity/features/settings/presentation/layout/web_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsive(mobile: MobileSettingsScreen(), desktop: WebSettingsScreen()),
    );
  }
}
