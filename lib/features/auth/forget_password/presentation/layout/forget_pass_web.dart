import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/top_image_widget.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';

class ForgetPassWeb extends StatefulWidget {
  const ForgetPassWeb({super.key});

  @override
  State<ForgetPassWeb> createState() => _ForgetPassWebState();
}

class _ForgetPassWebState extends State<ForgetPassWeb> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Center(
          child: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('reset_link_sent_message'.tr())),
                );
                // النافيجيشن هنا بس، بعد التأكد الفعلي من النجاح
                context.pushNamed(
                  AppRoutes.accessPassScreen,
                  extra: emailController.text.trim(),
                );
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('generic_error_message'.tr()),
                    backgroundColor: context.colors.error,
                  ),
                );
              }
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 56,
                  horizontal: 48,
                ),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TopImageWidget(
                        imageUrl: AppAssets.lockedEemail,
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "forgot your password?".tr(),
                        style: context.text.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "don't worry, just enter the email you signed up with and we'll send you a link to reset your password"
                            .tr(),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        label: "email".tr(),
                        hint: "email1".tr(),
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        validator: AppValidators.email,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 28),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return SizedBox(
                            width: double.infinity,
                            child: PrimaryButtonWidget(
                              isLoading: isLoading,
                              onPress: isLoading
                                  ? null
                                  : () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      context.read<AuthCubit>().sendResetLink(
                                        emailController.text.trim(),
                                      );
                                    },
                              buttonText: "send the link".tr(),
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "remember your password?".tr(),
                            style: context.text.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pushReplacementNamed(
                              AppRoutes.loginScreen,
                            ),
                            child: Text(
                              "login".tr(),
                              style: context.text.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
