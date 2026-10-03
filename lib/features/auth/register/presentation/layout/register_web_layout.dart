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
import 'package:warshity/core/widgets/web_settings_actions.dart';
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
      backgroundColor: context.colors.onSurface,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.surface,
                    context.colors.surfaceContainerLowest,
                  ],
                ),
              ),
            ),
          ),

          // Register content
          Positioned.fill(
            child: BlocConsumer<AuthCubit, AuthState>(
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
                      margin: const EdgeInsets.symmetric(vertical: 32),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: .center,
                            children: [
                              const SizedBox(height: 32),

                              // Logo
                              Image.asset(
                                AppAssets.logo,
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "create_account".tr(),
                                    style: context.text.bodyLarge?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "start".tr(),
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),

                              const HeightSpace(24),

                              // Shop name + Account name
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
                                    prefixIconData: Icons.store,
                                    iconSize: 20,
                                  ),
                                  const SizedBox(width: 16),
                                  CustomTextField(
                                    label: "accountname".tr(),
                                    hint: "thirdname".tr(),
                                    width: 270,
                                    controller: accountNameController,
                                    validator: AppValidators.accountName,
                                    borderRadius: AppRadius.sm,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIconData: Icons.person,
                                    iconSize: 20,
                                  ),
                                ],
                              ),

                              const HeightSpace(16),

                              // Email + Activity
                              Row(
                                children: [
                                  CustomTextField(
                                    label: "email".tr(),
                                    hint: "enter_your_email".tr(),
                                    width: 270,
                                    controller: emailController,
                                    validator: AppValidators.email,
                                    borderRadius: AppRadius.sm,

                                    // Changed from phone to email.
                                    keyboardType: TextInputType.emailAddress,

                                    prefixIconData: Icons.email,
                                    iconSize: 20,
                                  ),
                                  const SizedBox(width: 16),
                                  CustomDropdown(
                                    label: "activetype".tr(),
                                    hint: "select_activity".tr(),
                                    validator: (value) =>
                                        AppValidators.dropdown(
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

                              const HeightSpace(16),

                              // Password + Confirm password
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
                                    prefixIconData: Icons.lock,
                                    iconSize: 20,
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
                                  const SizedBox(width: 16),
                                  CustomTextField(
                                    label: "confirm_password".tr(),
                                    hint: "hash".tr(),
                                    width: 270,
                                    controller: confirmPasswordController,
                                    validator: AppValidators.password,
                                    prefixIconData: Icons.lock,
                                    iconSize: 20,
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
                                  ),
                                ],
                              ),

                              const HeightSpace(16),

                              // Terms
                              CheckboxWidget(
                                width: 350,
                                value: ischecked,
                                onChanged: (value) {
                                  setState(() {
                                    ischecked = value!;
                                  });
                                },
                              ),

                              const HeightSpace(32),

                              // Register button
                              PrimaryButtonWidget(
                                buttonText: "create_account1".tr(),
                                onPress: () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  if (!ischecked) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "validator_terms_required".tr(),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final user = UserModel(
                                    uid: '',
                                    shopName: shopNameController.text.trim(),
                                    ownerName: accountNameController.text
                                        .trim(),
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
                                borderRadius: AppRadius.sm,
                                buttonColor: context.colors.primary,
                                textColor: context.colors.onPrimary,
                                fontSize: context.text.titleLarge?.fontSize,
                                height: 56,
                                width: 434,
                              ),

                              const HeightSpace(24),

                              // Continue divider
                              Dividerwidget(
                                child: Text(
                                  "continue".tr(),
                                  style: context.text.bodyLarge,
                                ),
                              ),

                              const HeightSpace(24),

                              // Social buttons
                              Row(
                                children: [
                                  OutlinedButtonWidget(
                                    iconPath: AppAssets.google,
                                    iconHeight: 35,
                                    iconWidth: 35,
                                    width: 270,
                                    height: 48,
                                    onPressed: () {
                                      context
                                          .read<AuthCubit>()
                                          .signInWithGoogle();
                                    },
                                  ),
                                  const Spacer(),
                                  OutlinedButtonWidget(
                                    icon: Icon(
                                      Icons.facebook_rounded,
                                      size: 35,
                                      color: Colors.blue.shade900,
                                    ),
                                    width: 270,
                                    onPressed: () {
                                      context
                                          .read<AuthCubit>()
                                          .signInWithFacebook();
                                    },
                                    height: 48,
                                  ),
                                ],
                              ),

                              const HeightSpace(24),

                              // Login footer
                              FooterWidget(
                                text1: "have_account",
                                text2: "login",
                                onPress: () {
                                  context.pushNamed(AppRoutes.loginScreen);
                                },
                              ),

                              const HeightSpace(16),

                              // Bottom divider
                              Dividerwidget(
                                child: Image.asset(
                                  AppAssets.logo,
                                  width: 24,
                                  height: 24,
                                ),
                              ),

                              const SizedBox(height: 24),
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

          // Web settings
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
