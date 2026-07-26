import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/auth/register/presentation/layout/register_mobile_layout.dart';
import 'package:warshity/features/auth/register/presentation/layout/register_web_layout.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppResponsive(
        mobile: RegisterMobileLayout(),
        desktop: RegisterWebLayout(),
      ),
    );
  }
}