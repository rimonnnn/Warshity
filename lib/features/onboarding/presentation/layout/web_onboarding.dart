// lib/features/onboarding/presentation/layouts/web_onboarding.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/onboarding/data/models/onboarding_model.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:warshity/features/onboarding/presentation/widgets/dots_indecator_widget.dart';
import 'package:warshity/features/onboarding/presentation/widgets/page_view_widget.dart';
import 'package:warshity/features/onboarding/presentation/widgets/top_text.dart';

class WebOnboarding extends StatefulWidget {
  const WebOnboarding({super.key});

  @override
  State<WebOnboarding> createState() => _WebOnboardingState();
}

class _WebOnboardingState extends State<WebOnboarding> {
  final PageController pageController = PageController();

  int currentPage = 0;

  Future<void> _completeOnboardingAndNavigate() async {
    await getIt<OnboardingLocalDataSource>().completeOnboarding();
    if (mounted) context.pushReplacementNamed(AppRoutes.loginScreen);
  }

  Future<void> _goToNextPage() async {
    if (currentPage == onboardingItems.length - 1) {
      await _completeOnboardingAndNavigate();
    } else {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == onboardingItems.length - 1;

    return Scaffold(
      backgroundColor: context.colors.surfaceContainerHighest,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isLastPage)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TopText(
                      onTap: _completeOnboardingAndNavigate,
                      text: 'skip'.tr(),
                    ),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: onboardingItems.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = onboardingItems[index];
                      return PageViewWidget(
                        width: 300,
                        height: 300,
                        imageUrl: item.image,
                        title: item.title.tr(),
                        describtion: item.descreption.tr(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                DotsIndecatorWidget(
                  pageController: pageController,
                  count: onboardingItems.length,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 6,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButtonWidget(
                    buttonText: isLastPage ? "get started".tr() : "next".tr(),
                    textColor: context.colors.onPrimary,
                    fontSize: 18,
                    onPress: _goToNextPage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
