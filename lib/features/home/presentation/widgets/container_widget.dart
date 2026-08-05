import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';

class ContainerWidget extends StatelessWidget {
  const ContainerWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.padding,
  });

  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        return Container(
          width: width ?? double.infinity,
          height: height ?? (isDesktop ? 220 : 150),
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 24,
                vertical: isDesktop ? 32 : 24,
              ),
          decoration: BoxDecoration(
            color: color ?? context.colors.primary,
            borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
          ),
          child: Row(
            textDirection: .rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "welcome_actor".tr(),
                      textAlign: TextAlign.end,
                      style: context.text.headlineMedium?.copyWith(
                        color: context.colors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "welcome_message".tr(),
                      textAlign: TextAlign.end,
                      style: context.text.bodyLarge?.copyWith(
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              Image.asset(
                AppAssets.homeicon,
                width: isDesktop ? 120 : 90,
                height: isDesktop ? 120 : 90,
                color: context.colors.onPrimary,
              ),
            ],
          ),
        );
      },
    );
  }
}
