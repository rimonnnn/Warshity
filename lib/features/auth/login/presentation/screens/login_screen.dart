import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/auth/login/presentation/layout/login_mobile_layout.dart';
import 'package:warshity/features/auth/login/presentation/layout/login_web_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsive(mobile: LoginMobileLayout(), desktop: LoginWebLayout()),
    );
  }
}
