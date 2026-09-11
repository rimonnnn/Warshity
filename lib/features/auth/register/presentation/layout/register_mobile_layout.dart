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
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:warshity/features/auth/register/presentation/widgets/checkbox_widget.dart';
import 'package:warshity/features/auth/register/presentation/widgets/custom_drobdown.dart';

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

  late final Stream<List<String>> categoriesStream;

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

    categoriesStream = context.read<AuthCubit>().categoriesStream;
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
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HeightSpace(30.h),

                    CustomLogo(
                      width: 80.w,
                      height: 80.h,

                      logoPath: AppAssets.logo,
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
                    HeightSpace(16),

                    Form(
                      key: _formKey,
                      child: Container(
                        width: 358.w,
                        height: 1040.h,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),

                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            children: [
                              HeightSpace(24.h),

                              CustomTextField(
                                label: "labelname_of_shop".tr(),
                                hint: "hintname_of_shop".tr(),
                                keyboardType: TextInputType.text,
                                prefixIconData: Icons.store,
                                controller: shopNameController,
                                validator: AppValidators.shopName,
                              ),

                              HeightSpace(16.h),

                              CustomTextField(
                                label: "accountname".tr(),
                                hint: "enter_your_name".tr(),
                                keyboardType: TextInputType.text,
                                prefixIconData: Icons.person,
                                controller: accountNameController,
                                validator: AppValidators.accountName,
                              ),

                              HeightSpace(16.h),

                              CustomTextField(
                                label: "email".tr(),
                                hint: "enter_your_email".tr(),
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                prefixIconData: Icons.email,
                                validator: AppValidators.email,
                              ),

                              HeightSpace(16.h),

                              StreamBuilder<List<String>>(
                                stream: categoriesStream,
                                builder: (context, snapshot) {
                                  final firestoreCategories =
                                      snapshot.data ?? [];

                                  final allActivities = <String>{
                                    ...activities,
                                    ...firestoreCategories,
                                  }.toList();

                                  return CustomDropdown(
                                    label: "activetype".tr(),
                                    hint: "select_activity".tr(),
                                    validator: (value) =>
                                        AppValidators.dropdown(
                                          value,
                                          'select_activity'.tr(),
                                        ),
                                    items: allActivities,
                                    selectedItem: selectedActivity,
                                    prefixIconData: Icons.category_outlined,

                                    onSelected: (value) {
                                      setState(() {
                                        selectedActivity = value;
                                      });
                                    },

                                    onAddCategory: (categoryName) async {
                                      await context
                                          .read<AuthCubit>()
                                          .addCategory(categoryName);
                                    },
                                  );
                                },
                              ),

                              HeightSpace(16.h),

                              CustomTextField(
                                label: "password".tr(),
                                hint: "hash".tr(),
                                keyboardType: TextInputType.text,
                                prefixIconData: Icons.lock,
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
                                prefixIconData: Icons.lock,
                                controller: confirmPasswordController,
                                validator: (value) =>
                                    AppValidators.confirmPassword(
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
                                width: 250.w,
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
                                fontSize: context.text.titleMedium?.fontSize,
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

                                  setState(() {
                                    selectedActivity = null;
                                  });
                                },

                                suffixicon: true,
                                borderRadius: AppRadius.sm,
                                buttonColor: context.colors.primary,
                                textColor: context.colors.onPrimary,
                                iconData: Icons.arrow_forward,
                                iconSize: 24.sp,
                                iconeColor: context.colors.onPrimary,
                                height: 56.h,
                                width: 310.w,
                              ),

                              HeightSpace(40.h),

                              Dividerwidget(
                                child: Text(
                                  "continue".tr(),
                                  style: context.text.bodyMedium,
                                ),
                              ),

                              HeightSpace(20.h),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  OutlinedButtonWidget(
                                    iconPath: AppAssets.google,
                                    iconHeight: 35.h,
                                    iconWidth: 35.w,
                                    width: 120.w,
                                    height: 50.h,
                                    onPressed: () {
                                      context
                                          .read<AuthCubit>()
                                          .signInWithGoogle();
                                    },
                                  ),

                                  WidthSpace(16),
                                  OutlinedButtonWidget(
                                    icon: Icon(
                                      Icons.facebook_rounded,
                                      size: 40.sp,
                                      color: Colors.blue.shade900,
                                    ),
                                    width: 120.w,
                                    height: 50.h,
                                    onPressed: () {
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

                    HeightSpace(32.h),

                    FooterWidget(
                      text1: "have_account",
                      text2: "login",
                      onPress: () {
                        context.pushNamed(AppRoutes.loginScreen);
                      },
                    ),

                    HeightSpace(24.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Dividerwidget(
                        child: Image.asset(
                          AppAssets.logo,
                          width: 30.w,
                          height: 30.h,
                        ),
                      ),
                    ),

                    HeightSpace(40.h),
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
