import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/custom_logo.dart';
import 'package:warshity/core/widgets/divider_widget.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/core/widgets/outlined_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';

class LoginMobileLayout extends StatefulWidget {
  const LoginMobileLayout({super.key});

  @override
  State<LoginMobileLayout> createState() => _LoginMobileLayoutState();
}

class _LoginMobileLayoutState extends State<LoginMobileLayout> {
  bool isvisible = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              showAnimatedSnackDialog(
                context,
                message: state.message.tr(),
                type: AnimatedSnackBarType.error,
              );
            }

            if (state is LoginSuccess) {
              showAnimatedSnackDialog(
                context,
                message: state.message.tr(),
                type: AnimatedSnackBarType.success,
              );
              context.pushReplacementNamed(AppRoutes.homeScreen);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            // الشاشة تفضل ظاهرة دايمًا؛ الـ loading يتحصر في الزرار نفسه
            return SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    HeightSpace(30),
                    CustomLogo(
                      width: 50.w,
                      height: 52.h,
                      borderRadius: AppRadius.circular,
                      logoPath: AppAssets.loginicon,
                    ),
                    HeightSpace(16.h),
                    Text("welcome".tr(), style: context.text.headlineLarge),
                    HeightSpace(8.h),
                    Text(
                      "startlogin".tr(),
                      style: context.text.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    HeightSpace(32),
                    Form(
                      key: _formKey,
                      child: Container(
                        width: 358.w,
                        height: 620.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          color: context.colors.surfaceContainerLow,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24.sp),
                          child: Column(
                            children: [
                              CustomTextField(
                                label: "email".tr(),
                                hint: "email1".tr(),
                                borderRadius: AppRadius.sm,
                                controller: emailController,
                                validator: AppValidators.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              HeightSpace(18.h),
                              CustomTextField(
                                label: "password".tr(),
                                hint: "hash".tr(),
                                borderRadius: AppRadius.sm,
                                keyboardType: TextInputType.visiblePassword,
                                prefixIcon: AppAssets.password,
                                obscureText: isvisible,
                                controller: passwordController,
                                validator: AppValidators.password,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isvisible = !isvisible;
                                    });
                                  },
                                  icon: Icon(
                                    isvisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                              HeightSpace(10.h),
                              Align(
                                alignment: context.locale.languageCode == "ar"
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context.pushNamed(
                                            AppRoutes.forgetPassScreen,
                                          );
                                        },
                                  child: Text(
                                    "forget".tr(),
                                    style: context.text.bodyLarge,
                                  ),
                                ),
                              ),
                              HeightSpace(20.h),
                              PrimaryButtonWidget(
                                borderRadius: AppRadius.sm,
                                buttonColor: context.colors.primary,
                                textColor: context.colors.onPrimary,
                                fontSize: context.text.titleLarge?.fontSize,
                                height: 56.h,
                                width: 310.w,
                                buttonText: "login".tr(),
                                isLoading: isLoading,
                                onPress: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthCubit>().login(
                                            email: emailController.text.trim(),
                                            password: passwordController.text
                                                .trim(),
                                          );
                                        }
                                      },
                              ),
                              HeightSpace(32),
                              Dividerwidget(
                                child: Text(
                                  "continue".tr(),
                                  style: context.text.bodyLarge,
                                ),
                              ),
                              HeightSpace(16),
                              Row(
                                children: [
                                  OutlinedButtonWidget(
                                    iconPath: AppAssets.google,
                                    iconWidth: 35.w,
                                    iconHeight: 35.h,
                                    width: 130.w,
                                    height: 48.h,
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context
                                                .read<AuthCubit>()
                                                .signInWithGoogle();
                                          },
                                  ),
                                  const Spacer(),
                                  OutlinedButtonWidget(
                                    iconPath: AppAssets.facebook,
                                    iconWidth: 35.w,
                                    iconHeight: 35.h,
                                    width: 130.w,
                                    height: 48.h,
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context
                                                .read<AuthCubit>()
                                                .signInWithFacebook();
                                          },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    HeightSpace(10.h),
                    FooterWidget(
                      text1: "Don't_have_account",
                      text2: "create_account2",
                      onPress: isLoading
                          ? null
                          : () {
                              context.pushNamed(AppRoutes.registerScreen);
                            },
                    ),
                    HeightSpace(24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22.sp),
                      child: Dividerwidget(
                        child: Image.asset(
                          AppAssets.footer,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    HeightSpace(60),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
