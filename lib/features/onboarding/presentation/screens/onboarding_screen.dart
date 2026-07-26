import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/onboarding/presentation/layout/mobile_onboarding.dart';
import 'package:warshity/features/onboarding/presentation/layout/web_onboarding.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppResponsive(mobile: MobileOnboarding(), desktop: WebOnboarding());
  }
}
