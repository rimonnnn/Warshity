import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/auth/access_password/presentation/layout/access_pass_mobile.dart';
import 'package:warshity/features/auth/access_password/presentation/layout/access_pass_web.dart';

class AccessPassScreen extends StatelessWidget {
  const AccessPassScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: AccessPassMobile(email: email),
      desktop: AccessPassWeb(email: email),
    );
  }
}