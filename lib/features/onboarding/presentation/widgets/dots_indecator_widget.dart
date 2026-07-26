import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class DotsIndecatorWidget extends StatelessWidget {
  final PageController pageController;
  final int count;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotHeight;
  final double dotWidth;
  final double expansionFactor;
  final double spacing;

  const DotsIndecatorWidget({
    super.key,
    required this.pageController,
    required this.count,
    this.activeColor,
    this.inactiveColor,
    this.dotHeight = 8,
    this.dotWidth = 8,
    this.expansionFactor = 3,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: pageController,
      count: count,
      effect: ExpandingDotsEffect(
        dotHeight: dotHeight,
        dotWidth: dotWidth,
        expansionFactor: expansionFactor,
        spacing: spacing,
        activeDotColor: activeColor ?? context.colors.primary,
        dotColor: inactiveColor ?? context.colors.outlineVariant,
      ),
    );
  }
}
