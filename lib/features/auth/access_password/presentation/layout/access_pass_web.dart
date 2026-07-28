import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/custom_outline_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/top_image_widget.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';

class AccessPassWeb extends StatefulWidget {
  const AccessPassWeb({super.key, required this.email});

  final String email;

  @override
  State<AccessPassWeb> createState() => _AccessPassWebState();
}

class _AccessPassWebState extends State<AccessPassWeb> {
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
    final gmailWebUri = Uri.parse('https://mail.google.com/mail/u/0/#inbox');

    try {
      if (await canLaunchUrl(gmailWebUri)) {
        await launchUrl(gmailWebUri, webOnlyWindowName: '_blank');
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
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 64,
                  horizontal: 56,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.shadow.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: context.colors.shadow.withValues(alpha: 0.08),
                      blurRadius: 48,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TopImageWidget(
                      imageUrl: AppAssets.sucsessEemail,
                      width: 110,
                      height: 110,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      "the link has been sent".tr(),
                      style: context.text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "we sent you a link to reset your password on the email:"
                          .tr(),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.email,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "if you can't find the message, check in Spam or Junk"
                          .tr(),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: PrimaryButtonWidget(
                            isLoading: isLoading,
                            onPress: isLoading ? null : _openMailApp,
                            buttonText: "open the mail app".tr(),
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
                          "didn't the message reach you?".tr(),
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: _canResend ? _resend : null,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "resend".tr(),
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _canResend
                                  ? context.colors.primary
                                  : context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (!_canResend) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                              style: context.text.labelMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: CustomOutlineButtonWidget(
                        onPress: () =>
                            context.pushReplacementNamed(AppRoutes.loginScreen),
                        buttonText: "back to login".tr(),
                        fontSize: 18,
                        borderWidth: 1,
                        
                      ),
                    ),
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
