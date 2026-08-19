import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/home/presentation/layout/mobile_home.dart';
import 'package:warshity/features/home/presentation/layout/web_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsive(mobile: MobileHome(), desktop: WebHome()),
    );
  }
}
