import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/auth/forget_password/presentation/layout/forget_pass_mobile.dart';
import 'package:warshity/features/auth/forget_password/presentation/layout/forget_pass_web.dart';

class ForgetPassScreen extends StatelessWidget {
  const ForgetPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppResponsive(mobile: ForgetPassMobile(), desktop: ForgetPassWeb());
  }
}
