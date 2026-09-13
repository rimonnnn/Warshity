import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/onboarding/data/models/onboarding_model.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:warshity/features/onboarding/presentation/widgets/dots_indecator_widget.dart';
import 'package:warshity/features/onboarding/presentation/widgets/page_view_widget.dart';
import 'package:warshity/features/onboarding/presentation/widgets/top_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();

  int currentPage = 0;

  Future<void> _completeOnboardingAndNavigate() async {
    await getIt<OnboardingLocalDataSource>().completeOnboarding();

    if (mounted) {
      context.pushReplacementNamed(AppRoutes.loginScreen);
    }
  }

  Future<void> _goToNextPage() async {
    if (currentPage == onboardingItems.length - 1) {
      await _completeOnboardingAndNavigate();
    } else {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark ? AppAssets.darkOnboarding : AppAssets.lightOnboarding,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  // Skip
                  if (!isLastPage)
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: TopText(
                        onTap: _completeOnboardingAndNavigate,
                        text: 'skip'.tr(),
                      ),
                    ),

                  const Spacer(),

                  // Onboarding content
                  SizedBox(
                    height: 250.h,
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

                        return AnimatedBuilder(
                          animation: pageController,
                          child: PageViewWidget(
                            width: 358.w,
                            title: item.title.tr(),
                            describtion: item.description.tr(),
                          ),
                          builder: (context, child) {
                            double page = 0;

                            if (pageController.hasClients &&
                                pageController.position.haveDimensions) {
                              page = pageController.page! - index;
                            }

                            final distance = page.abs().clamp(0.0, 1.0);

                            final scale = 1.0 - (distance * 0.06);
                            final opacity = 1.0 - (distance * 0.25);
                            final translateX = page * 16.w;

                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(translateX, 0),
                                child: Transform.scale(
                                  scale: scale,
                                  child: child,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  HeightSpace(160),

                  // Indicator
                  DotsIndecatorWidget(
                    pageController: pageController,
                    count: onboardingItems.length,
                    dotHeight: 8.h,
                    dotWidth: 8.w,
                    spacing: 6.w,
                  ),

                  HeightSpace(24),

                  // CTA
                  PrimaryButtonWidget(
                    buttonColor: context.colors.primary,
                    buttonText: isLastPage ? 'get started'.tr() : 'next'.tr(),
                    textColor: context.colors.onPrimary,
                    fontSize: 18.sp,
                    iconData: isLastPage
                        ? Icons.check_circle
                        : Icons.arrow_forward,
                    iconSize: 24.sp,
                    iconeColor: context.colors.onPrimary,
                    onPress: _goToNextPage,
                  ),

                  HeightSpace(24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
