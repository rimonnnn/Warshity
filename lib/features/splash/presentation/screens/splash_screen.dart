// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/splash/presentation/layout/mobile_splash.dart';
import 'package:warshity/features/splash/presentation/layout/web_splash.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: const MobileSplash(),
      desktop: const WebSplash(),
    );
  }
}
