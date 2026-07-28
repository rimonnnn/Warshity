import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/button_back_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/remember_password_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/core/widgets/top_image_widget.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';

class ForgetPassMobile extends StatefulWidget {
  const ForgetPassMobile({super.key});

  @override
  State<ForgetPassMobile> createState() => _ForgetPassMobileState();
}

class _ForgetPassMobileState extends State<ForgetPassMobile> {
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.lg),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HeightSpace(22),
                    const ButtonBackWidget(),
                    HeightSpace(22),
                    TopImageWidget(imageUrl: AppAssets.lockedEemail),
                    HeightSpace(18),
                    Text(
                      "forgot your password?".tr(),
                      style: context.text.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    HeightSpace(8),
                    Text(
                      "don't worry, just enter the email you signed up with and we'll send you a link to reset your password"
                          .tr(),
                      style: context.text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    HeightSpace(22),
                    CustomTextField(
                      label: "email".tr(),
                      hint: "email1".tr(),
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      validator: AppValidators.email,
                    ),
                    HeightSpace(22),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return PrimaryButtonWidget(
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
                          fontSize: 20.sp,
                        );
                      },
                    ),
                    HeightSpace(30),
                    RememberPasswordWidget(
                      text: "remember your password?".tr(),
                    ),
                    HeightSpace(24),
                    TextButton(
                      onPressed: () =>
                          context.pushReplacementNamed(AppRoutes.loginScreen),
                      child: Text(
                        "login".tr(),
                        style: context.text.headlineSmall,
                      ),
                    ),
                    HeightSpace(12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
