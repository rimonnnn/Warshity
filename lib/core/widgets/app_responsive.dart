import 'package:flutter/material.dart';

class AppResponsive extends StatelessWidget {
  final Widget mobile;

  final Widget? tablet;

  final Widget desktop;

  const AppResponsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile;
        }

        if (constraints.maxWidth < 1024) {
          return tablet ?? desktop;
        }

        return desktop;
      },
    );
  }
}
