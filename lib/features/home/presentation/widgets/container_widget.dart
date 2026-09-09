import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';

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
        final isDesktop = constraints.maxWidth >= 900;
        final isArabic = context.locale.languageCode == "ar";

        final imageSize = isDesktop ? 120.0 : 70.0;
        final horizontalPadding = isDesktop ? 40.0 : 20.0;

        return Container(
          width: width ?? double.infinity,
          height: height ?? (isDesktop ? 220 : 150),
          decoration: BoxDecoration(
            color: color ?? context.colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
          ),
          child: Stack(
            children: [
              /// الصورة
              Positioned(
                left: isArabic ? horizontalPadding : null,
                right: isArabic ? null : horizontalPadding,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.asset(
                    AppAssets.logo,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    // color: context.colors.primaryContainer.withOpacity(0.5),
                  ),
                ),
              ),

              /// النص
              Positioned.fill(
                child: Padding(
                  padding: isArabic
                      ? EdgeInsets.only(
                          left: horizontalPadding + imageSize + 20,
                          right: horizontalPadding,
                        )
                      : EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding + imageSize + 20,
                        ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, authState) {
                          String ownerName = '';

                          if (authState is UserLoaded) {
                            ownerName = authState.user.ownerName;
                          }

                          return Text(
                            '${"welcome_actor".tr()} $ownerName',
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                (isDesktop
                                        ? context.text.headlineMedium
                                        : context.text.headlineSmall)
                                    ?.copyWith(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                          );
                        },
                      ),
                      SizedBox(height: isDesktop ? 10 : 6),

                      Text(
                        "welcome_message".tr(),
                        textAlign: TextAlign.start,
                        maxLines: isArabic ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (isDesktop
                                    ? context.text.bodyLarge
                                    : context.text.bodyMedium)
                                ?.copyWith(color: context.colors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
