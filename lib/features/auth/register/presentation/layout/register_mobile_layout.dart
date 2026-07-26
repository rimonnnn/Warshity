import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/contstants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/outlined_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:warshity/features/auth/register/presentation/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/register/presentation/cubit/auth_state.dart';
import 'package:warshity/features/auth/register/presentation/widgets/checkbox_widget.dart';
import 'package:warshity/features/auth/register/presentation/widgets/custom_drobdown.dart';
import 'package:warshity/features/auth/register/presentation/widgets/custom_logo.dart';

class RegisterMobileLayout extends StatefulWidget {
  const RegisterMobileLayout({super.key});

  @override
  State<RegisterMobileLayout> createState() => _RegisterMobileLayoutState();
}

class _RegisterMobileLayoutState extends State<RegisterMobileLayout> {
  final List<String> activities = [
    "activities.carpentry".tr(),
    "activities.plumbing".tr(),
    "activities.electricity".tr(),
    "activities.painting".tr(),
    "activities.blacksmith".tr(),
    "activities.ac".tr(),
  ];
  String? selectedActivity;
  bool isvisible = true;
  bool isvisible2 = true;
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController shopNameController = TextEditingController();

  TextEditingController accountNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    shopNameController = TextEditingController();
    accountNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    shopNameController.dispose();
    accountNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              showAnimatedSnackDialog(
                context,
                message: state.message,
                type: AnimatedSnackBarType.success,
              );
            }

            if (state is AuthError) {
              showAnimatedSnackDialog(
                context,
                message: state.message,
                type: AnimatedSnackBarType.error,
              );
            }

            if (state is EmailVerificationSent) {
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
              child: Column(
                children: [
                  HeightSpace(30.h),
                  CustomLogo(
                    width: 64.w,
                    height: 64.h,
                    borderRadius: AppRadius.lg,
                    logoPath: AppAssets.registerLogo,
                  ),
                  Text(
                    "create_account".tr(),
                    style: context.text.headlineLarge,
                  ),
                  Text(
                    "start".tr(),
                    style: context.text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  Form(
                    key: _formKey,
                    child: Container(
                      width: 358.w,
                      height: 1150.h,
                      color: context.colors.surfaceContainerLow,
                      child: Column(
                        children: [
                          HeightSpace(24.h),
                          CustomTextField(
                            label: "labelname_of_shop".tr(),
                            hint: "hintname_of_shop".tr(),
                            keyboardType: TextInputType.text,
                            prefixIcon: AppAssets.shopname,
                            controller: shopNameController,
                            validator: AppValidators.shopName,
                          ),
                          HeightSpace(16.h),
                          CustomTextField(
                            label: "accountname".tr(),
                            hint: "thirdname".tr(),
                            keyboardType: TextInputType.text,
                            prefixIcon: AppAssets.person,
                            controller: accountNameController,
                            validator: AppValidators.accountName,
                          ),
                          HeightSpace(16.h),
                          CustomTextField(
                            label: "email".tr(),
                            hint: "email1".tr(),
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            validator: AppValidators.email,
                          ),
                          HeightSpace(16.h),
                          CustomDropdown(
                            label: "activetype".tr(),
                            hint: "select_activity".tr(),
                            validator: (value) => AppValidators.dropdown(
                              value,
                              'select_activity'.tr(),
                            ),
                            items: activities,
                            selectedItem: selectedActivity,
                            prefixIcon: AppAssets.activities,
                            onSelected: (value) {
                              setState(() {
                                selectedActivity = value;
                              });
                            },
                          ),
                          HeightSpace(16.h),
                          CustomTextField(
                            label: "password".tr(),
                            hint: "hash".tr(),
                            keyboardType: TextInputType.text,
                            prefixIcon: AppAssets.password,
                            obscureText: isvisible,
                            controller: passwordController,
                            validator: AppValidators.password,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isvisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  isvisible = !isvisible;
                                });
                              },
                            ),
                          ),
                          HeightSpace(16.h),
                          CustomTextField(
                            label: "confirm_password".tr(),
                            hint: "hash".tr(),
                            keyboardType: TextInputType.text,
                            prefixIcon: AppAssets.confirmPassword,
                            controller: confirmPasswordController,
                            validator: (value) => AppValidators.confirmPassword(
                              value,
                              passwordController.text,
                            ),
                            obscureText: isvisible2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isvisible2
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  isvisible2 = !isvisible2;
                                });
                              },
                            ),
                          ),
                          HeightSpace(16.h),
                          CheckboxWidget(
                            value: isChecked,

                            onChanged: (value) {
                              setState(() {
                                isChecked = value ?? false;
                              });
                            },
                          ),
                          HeightSpace(40.h),
                          PrimaryButtonWidget(
                            buttonText: "create_account1".tr(),
                            onPress: () {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              if (!isChecked) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "You must accept the terms and conditions",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final user = UserModel(
                                uid: '',
                                shopName: shopNameController.text.trim(),
                                ownerName: accountNameController.text.trim(),
                                email: emailController.text.trim(),
                                activity: selectedActivity!,
                              );

                              context.read<AuthCubit>().register(
                                user: user,
                                password: passwordController.text.trim(),
                              );
                              shopNameController.clear();
                              accountNameController.clear();
                              emailController.clear();
                              passwordController.clear();
                              confirmPasswordController.clear();
                              selectedActivity = null;
                            },
                            suffixicon: true,
                            iconPath: "arrowpath".tr(),
                            borderRadius: AppRadius.sm,
                            buttonColor: Theme.of(context).colorScheme.primary,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            fontSize: Theme.of(
                              context,
                            ).textTheme.titleLarge?.fontSize,
                            height: 56.h,
                            width: 310.w,
                          ),
                          HeightSpace(40.h),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: context.colors.onSurfaceVariant,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "continue".tr(),
                                  style: context.text.bodyLarge,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: context.colors.onSurfaceVariant,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          HeightSpace(16.h),
                          OutlinedButtonWidget(
                            buttonText: "google".tr(),
                            iconPath: AppAssets.google,
                            width: 310.w,
                            height: 50.h,
                          ),
                          HeightSpace(16.h),
                          OutlinedButtonWidget(
                            buttonText: "facebook".tr(),
                            iconPath: AppAssets.facebook,
                            width: 310.w,
                            height: 50.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                  HeightSpace(32.h),
                  RichText(
                    text: TextSpan(
                      text: "have_account".tr(),
                      style: context.text.bodyLarge,
                      children: [
                        TextSpan(
                          text: "login".tr(),
                          style: context.text.bodyLarge?.copyWith(
                            color: context.colors.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.pushReplacementNamed(
                              AppRoutes.loginScreen,
                            ),
                        ),
                      ],
                    ),
                  ),
                  HeightSpace(24.h),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: context.colors.onSurfaceVariant,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Image.asset(
                          AppAssets.footer,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: context.colors.onSurfaceVariant,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  HeightSpace(60.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
