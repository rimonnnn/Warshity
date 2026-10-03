import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:warshity/core/widgets/web_settings_actions.dart';
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
      body: Stack(
        children: [
          // ============================================================
          // Background + Login
          // ============================================================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.surface,
                    context.colors.surfaceContainerHighest,
                  ],
                ),
              ),
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

                    context.pushReplacementNamed(AppRoutes.mainScreen);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Form(
                        key: _formKey,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 550),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 48,
                              horizontal: 44,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: context.colors.shadow.withValues(
                                    alpha: 0.06,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: context.colors.shadow.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 48,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.logo,
                                  width: 80,
                                  height: 80,
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "welcome".tr(),
                                      style: context.text.bodyLarge?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "startlogin".tr(),
                                      style: context.text.bodySmall?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                      ),

                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                CustomTextField(
                                  height: 57,
                                  prefixIconData: Icons.email_outlined,
                                  iconSize: 20,
                                  width: double.infinity,
                                  label: "email".tr(),
                                  hint: "enter_your_email".tr(),
                                  borderRadius: 12,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailController,
                                  validator: AppValidators.email,
                                ),

                                const SizedBox(height: 20),

                                CustomTextField(
                                  height: 57,
                                  width: double.infinity,
                                  label: "password".tr(),
                                  hint: "hash".tr(),
                                  borderRadius: 12,
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: passwordController,
                                  validator: AppValidators.password,
                                  obscureText: isPasswordVisible,
                                  prefixIconData: Icons.lock_outline,
                                  iconSize: 20,
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

                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CheckboxWidget(
                                      width: 150,
                                      value: isAccepted,
                                      text: "remember_me".tr(),
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                              setState(() {
                                                isAccepted = value!;
                                              });
                                            },
                                    ),

                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              context.pushNamed(
                                                AppRoutes.forgetPassScreen,
                                              );
                                            },
                                      child: Text(
                                        "forget".tr(),
                                        style: context.text.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.primary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 28),

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: PrimaryButtonWidget(
                                    borderRadius: 12,
                                    buttonColor: context.colors.primary,
                                    textColor: context.colors.onPrimary,
                                    fontSize: 16,
                                    buttonText: "login".tr(),
                                    isLoading: isLoading,
                                    onPress: isLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              context.read<AuthCubit>().login(
                                                email: emailController.text
                                                    .trim(),
                                                password: passwordController
                                                    .text
                                                    .trim(),
                                              );
                                            }
                                          },
                                  ),
                                ),

                                const SizedBox(height: 28),

                                Dividerwidget(
                                  child: Text(
                                    "continue".tr(),
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: OutlinedButtonWidget(
                                          iconPath: AppAssets.google,
                                          iconWidth: 35,
                                          iconHeight: 35,
                                          borderRadius: 12,
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  context
                                                      .read<AuthCubit>()
                                                      .signInWithGoogle();
                                                },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: OutlinedButtonWidget(
                                          icon: Icon(
                                            Icons.facebook_rounded,
                                            size: 35,
                                            color: Colors.blue.shade900,
                                          ),
                                          borderRadius: 12,
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  context
                                                      .read<AuthCubit>()
                                                      .signInWithFacebook();
                                                },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                FooterWidget(
                                  text1: "Don't_have_account".tr(),
                                  text2: "create_account2".tr(),
                                  onPress: isLoading
                                      ? null
                                      : () => context.pushNamed(
                                          AppRoutes.registerScreen,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ============================================================
          // Web Settings
          // ============================================================
          const PositionedDirectional(
            top: 24,
            end: 32,
            child: WebSettingsActions(),
          ),
        ],
      ),
    );
  }
}
