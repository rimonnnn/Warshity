import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/outlined_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:warshity/features/auth/register/presentation/widgets/checkbox_widget.dart';
import 'package:warshity/features/auth/register/presentation/widgets/custom_drobdown.dart';

class RegisterWebLayout extends StatefulWidget {
  const RegisterWebLayout({super.key});

  @override
  State<RegisterWebLayout> createState() => _RegisterWebLayoutState();
}

class _RegisterWebLayoutState extends State<RegisterWebLayout> {
  bool isvisible = true;
  bool isvisible1 = true;
  final List<String> activities = [
    "activities.carpentry".tr(),
    "activities.plumbing".tr(),
    "activities.electricity".tr(),
    "activities.painting".tr(),
    "activities.blacksmith".tr(),
    "activities.ac".tr(),
  ];
  bool ischecked = false;
  String? selectedActivity;
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
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            showAnimatedSnackDialog(
              context,
              message: state.message,
              type: AnimatedSnackBarType.success,
            );
          } else if (state is AuthError) {
            showAnimatedSnackDialog(
              context,
              message: state.message,
              type: AnimatedSnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: 650,
                height: 790,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: context.colors.surfaceContainerLow,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: .center,
                      children: [
                        SizedBox(height: 32),
                        Image.asset(
                          AppAssets.registerLogo,
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                          color: context.colors.primary,
                        ),
                        Text(
                          "create_account".tr(),
                          style: context.text.headlineLarge,
                        ),
                        Text("start".tr(), style: context.text.bodyLarge),
                        HeightSpace(24),
                        Row(
                          children: [
                            CustomTextField(
                              label: "labelname_of_shop".tr(),
                              hint: "hintname_of_shop".tr(),
                              width: 270,
                              borderRadius: AppRadius.sm,
                              keyboardType: TextInputType.name,
                              controller: shopNameController,
                              validator: AppValidators.shopName,
                              prefixIcon: AppAssets.shopname,
                            ),
                            SizedBox(width: 16),
                            CustomTextField(
                              label: "accountname".tr(),
                              hint: "thirdname".tr(),
                              width: 270,
                              controller: accountNameController,
                              validator: AppValidators.accountName,
                              borderRadius: AppRadius.sm,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: AppAssets.person,
                            ),
                          ],
                        ),
                        HeightSpace(16),
                        Row(
                          children: [
                            CustomTextField(
                              label: "email".tr(),
                              hint: "email1".tr(),
                              width: 270,
                              controller: emailController,
                              validator: AppValidators.email,
                              borderRadius: AppRadius.sm,
                              keyboardType: TextInputType.phone,
                              prefixIcon: AppAssets.shopname,
                            ),
                            SizedBox(width: 16),
                            CustomDropdown(
                              label: "activetype".tr(),
                              hint: "select_activity".tr(),
                              validator: (value) => AppValidators.dropdown(
                                value,
                                "select_activity".tr(),
                              ),
                              items: activities,
                              width: 270,
                              selectedItem: selectedActivity,
                              onSelected: (value) {
                                setState(() {
                                  selectedActivity = value;
                                });
                              },
                              height: 48,
                              borderRadius: AppRadius.sm,
                            ),
                          ],
                        ),
                        HeightSpace(16),
                        Row(
                          children: [
                            CustomTextField(
                              label: "password".tr(),
                              hint: "hash".tr(),
                              width: 270,
                              controller: passwordController,
                              validator: AppValidators.password,
                              borderRadius: AppRadius.sm,
                              keyboardType: TextInputType.visiblePassword,
                              prefixIcon: AppAssets.shopname,
                              obscureText: isvisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isvisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: context.colors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isvisible = !isvisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            CustomTextField(
                              label: "confirm_password".tr(),
                              hint: "hash".tr(),
                              width: 270,
                              controller: confirmPasswordController,
                              validator: AppValidators.password,

                              borderRadius: AppRadius.sm,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: isvisible1,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isvisible1
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: context.colors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isvisible1 = !isvisible1;
                                  });
                                },
                              ),
                              prefixIcon: AppAssets.person,
                            ),
                          ],
                        ),
                        HeightSpace(16),
                        CheckboxWidget(
                          width: 350,
                          value: ischecked,
                          onChanged: (value) {
                            setState(() {
                              ischecked = value!;
                            });
                          },
                        ),
                        HeightSpace(32),
                        PrimaryButtonWidget(
                          buttonText: "create_account1".tr(),
                          onPress: () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            if (!ischecked) {
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
                          buttonColor: context.colors.primary,
                          textColor: context.colors.onPrimary,
                          fontSize: context.text.titleLarge?.fontSize,
                          height: 56,
                          width: 434,
                          buttonspacing: 0,
                        ),
                        HeightSpace(24),
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
                        HeightSpace(24),
                        Row(
                          children: [
                            OutlinedButtonWidget(
                              buttonText: "google".tr(),
                              iconPath: AppAssets.google,
                              width: 270,
                              height: 48,
                            ),
                            Spacer(),
                            OutlinedButtonWidget(
                              buttonText: "facebook".tr(),
                              iconPath: AppAssets.facebook,
                              width: 270,
                              height: 48,
                            ),
                          ],
                        ),
                        HeightSpace(24),
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
                        HeightSpace(16),
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
                      ],
                    ),
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
