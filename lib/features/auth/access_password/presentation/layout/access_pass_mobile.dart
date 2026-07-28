import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/custom_outline_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/remember_password_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/core/widgets/top_image_widget.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';

class AccessPassMobile extends StatefulWidget {
  const AccessPassMobile({super.key, required this.email});

  final String email;

  @override
  State<AccessPassMobile> createState() => _AccessPassMobileState();
}

class _AccessPassMobileState extends State<AccessPassMobile> {
  static const int _cooldownSeconds = 30;

  Timer? _timer;
  int _secondsRemaining = 0;

  bool get _canResend => _secondsRemaining == 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    setState(() => _secondsRemaining = _cooldownSeconds);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  void _resend() {
    if (!_canResend) return;
    context.read<AuthCubit>().sendResetLink(widget.email);
    _startCooldown();
  }

  Future<void> _openMailApp() async {
    // المحاولة الأولى: فتح تطبيق Gmail مباشرة (لو متثبت)
    final gmailUri = Uri.parse('googlegmail://');

    try {
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri);
        return;
      }
    } catch (_) {
      // نكمل للـ fallback
    }

    // Fallback: فتح تطبيق البريد الافتراضي على الجهاز
    final mailtoUri = Uri.parse('mailto:');
    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
        return;
      }
    } catch (_) {
      // تجاهل، هنعرض رسالة تحت
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('no_mail_app_found'.tr())));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.lg),
          child: SingleChildScrollView(
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is ForgotPasswordSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('reset_link_sent_message'.tr())),
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
                  HeightSpace(60),
                  TopImageWidget(imageUrl: AppAssets.sucsessEemail),
                  HeightSpace(18),
                  Text(
                    "the link has been sent".tr(),
                    style: context.text.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  HeightSpace(8),
                  Text(
                    "we sent you a link to reset your password on the email:"
                        .tr(),
                    style: context.text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  HeightSpace(8),
                  Text(
                    widget.email,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  HeightSpace(12),
                  Text(
                    "if you can't find the message, check in Spam or Junk".tr(),
                    style: context.text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  HeightSpace(22),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return PrimaryButtonWidget(
                        isLoading: isLoading,
                        onPress: isLoading ? null : _openMailApp,
                        buttonText: "open the mail app".tr(),
                        fontSize: 20.sp,
                      );
                    },
                  ),
                  HeightSpace(30),
                  RememberPasswordWidget(
                    text: "didn't the message reach you?".tr(),
                  ),
                  HeightSpace(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _canResend ? _resend : null,
                        child: Text(
                          "resend".tr(),
                          style: context.text.headlineSmall?.copyWith(
                            color: _canResend
                                ? context.colors.primary
                                : context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (!_canResend) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                            style: context.text.labelMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  HeightSpace(12),
                  CustomOutlineButtonWidget(
                    onPress: () =>
                        context.pushReplacementNamed(AppRoutes.loginScreen),
                    buttonText: "back to login".tr(),
                    fontSize: 18.sp,
                  ),
                  HeightSpace(22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
