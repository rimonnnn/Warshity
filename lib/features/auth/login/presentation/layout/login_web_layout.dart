import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/divider_widget.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/core/widgets/outlined_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';
import 'package:warshity/features/auth/register/presentation/widgets/checkbox_widget.dart';

class LoginWebLayout extends StatefulWidget {
  const LoginWebLayout({super.key});

  @override
  State<LoginWebLayout> createState() => _LoginWebLayoutState();
}

class _LoginWebLayoutState extends State<LoginWebLayout> {
  bool isPasswordVisible = true;
  bool isAccepted = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showAnimatedSnackDialog(
              context,
              message: state.message,
              type: AnimatedSnackBarType.error,
            );
          }
          if (state is LoginSuccess) {
            showAnimatedSnackDialog(
              context,
              message: state.message,
              type: AnimatedSnackBarType.success,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 415, vertical: 80),
                  width: 610,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    color: context.colors.surfaceContainerLow,
                  ),
                  child: Column(
                    children: [
                      HeightSpace(10),
                      Image.asset(
                        AppAssets.loginicon,
                        color: context.colors.primary,
                      ),
                      HeightSpace(16),
                      Text("welcome".tr(), style: context.text.headlineLarge),
                      HeightSpace(8),
                      Text(
                        "startlogin".tr(),
                        style: context.text.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      HeightSpace(32),
                      Padding(
                        padding: const EdgeInsets.all(33),
                        child: Column(
                          children: [
                            CustomTextField(
                              label: "email".tr(),
                              hint: "email1".tr(),
                              borderRadius: 12,
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              validator: AppValidators.email,
                            ),
                            HeightSpace(24),
                            CustomTextField(
                              label: "password".tr(),
                              hint: "hash".tr(),
                              borderRadius: 12,
                              keyboardType: TextInputType.visiblePassword,
                              prefixIcon: AppAssets.password,
                              controller: passwordController,
                              validator: AppValidators.password,
                              
                              obscureText: isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: context.colors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            HeightSpace(16),
                            Align(
                              alignment: context.locale.languageCode == "ar"
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  context.pushNamed(AppRoutes.forgetPassScreen);
                                },
                                child: Text(
                                  "forget".tr(),
                                  style: context.text.bodyLarge?.copyWith(
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                            ),
                            HeightSpace(16),
                            CheckboxWidget(
                              value: isAccepted,
                              width: 200,
                              text: "remember_me".tr(),
                              onChanged: (value) {
                                setState(() {
                                  isAccepted = value!;
                                });
                              },
                            ),
                            HeightSpace(24),
                            PrimaryButtonWidget(
                              borderRadius: 8,
                              buttonColor: context.colors.primary,
                              textColor: context.colors.onPrimary,
                              fontSize: context.text.titleLarge?.fontSize,
                              height: 48,
                              width: 384,
                              buttonText: "login".tr(),
                              onPress: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                                }
                              },
                            ),
                            HeightSpace(32),
                            Dividerwidget(
                              child: Text(
                                "continue".tr(),
                                style: context.text.bodyLarge?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            HeightSpace(32),
                            Row(
                              children: [
                                OutlinedButtonWidget(
                                  buttonText: "google".tr(),
                                  iconPath: AppAssets.google,
                                  width: 270,
                                  borderRadius: 8,
                                  height: 48,
                                  onPressed: () {
                                    context
                                        .read<AuthCubit>()
                                        .signInWithGoogle();
                                  },
                                ),
                                Spacer(),
                                OutlinedButtonWidget(
                                  buttonText: "facebook".tr(),
                                  iconPath: AppAssets.facebook,
                                  width: 270,
                                  onPressed: () {
                                    context
                                        .read<AuthCubit>()
                                        .signInWithFacebook();
                                  },
                                  borderRadius: 8,
                                  height: 48,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      HeightSpace(24),
                      FooterWidget(
                        text1: "Don't_have_account",
                        text2: "create_account2",
                        onPress: () =>
                            context.pushNamed(AppRoutes.registerScreen),
                      ),
                      HeightSpace(24),
                      Dividerwidget(
                        child: Image.asset(
                          AppAssets.footer,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
