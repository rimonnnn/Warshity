import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/onboarding/data/models/onboarding_model.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:warshity/features/onboarding/presentation/widgets/dots_indecator_widget.dart';
import 'package:warshity/features/onboarding/presentation/widgets/page_view_widget.dart';
import 'package:warshity/features/onboarding/presentation/widgets/top_text.dart';

class MobileOnboarding extends StatefulWidget {
  const MobileOnboarding({super.key});

  @override
  State<MobileOnboarding> createState() => _MobileOnboardingState();
}

class _MobileOnboardingState extends State<MobileOnboarding> {
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isLastPage)
                TopText(
                  onTap: _completeOnboardingAndNavigate,
                  text: 'skip'.tr(),
                ),
              HeightSpace(90),
              Expanded(
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
                      width: 358.w,
                      height: 358.h,
                      imageUrl: item.image,
                      title: item.title.tr(),
                      describtion: item.descreption.tr(),
                    );
                  },
                ),
              ),
              HeightSpace(60),
              DotsIndecatorWidget(
                pageController: pageController,
                count: onboardingItems.length,
                dotHeight: 8.h,
                dotWidth: 8.w,
                spacing: 6.w,
              ),
              HeightSpace(24),
              PrimaryButtonWidget(
                buttonText: isLastPage ? "get started".tr() : "next".tr(),
                textColor: context.colors.onPrimary,
                fontSize: 18.sp,
                onPress: _goToNextPage,
              ),
              HeightSpace(24),
            ],
          ),
        ),
      ),
    );
  }
}
