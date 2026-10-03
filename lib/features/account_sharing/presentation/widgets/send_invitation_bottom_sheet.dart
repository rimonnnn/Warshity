import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';

import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class SendInvitationBottomSheet extends StatefulWidget {
  const SendInvitationBottomSheet({super.key});

  @override
  State<SendInvitationBottomSheet> createState() =>
      _SendInvitationBottomSheetState();
}

class _SendInvitationBottomSheetState extends State<SendInvitationBottomSheet> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInvitation() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showAnimatedSnackDialog(
        context,
        message: 'email_is_required'.tr(),
        type: AnimatedSnackBarType.error,
      );
      return;
    }

    context.read<AccountSharingCubit>().sendInvitation(email: email);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return BlocListener<AccountSharingCubit, AccountSharingState>(
      listener: (context, state) {
        if (state is AccountInvitationSent) {
          showAnimatedSnackDialog(
            context,
            message: 'invitation_sent_successfully'.tr(),
            type: AnimatedSnackBarType.success,
          );

          Navigator.of(context).pop();
        }

        if (state is AccountSharingError) {
          showAnimatedSnackDialog(
            context,
            message: state.message,
            type: AnimatedSnackBarType.error,
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 12),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.share_outlined,
                        color: colors.primary,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'share_account'.tr(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            'share_account_description'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Text(
                  'email'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 9),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    _sendInvitation();
                  },
                  decoration: InputDecoration(
                    hintText: 'enter_account_email'.tr(),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colors.primary,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.40),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                BlocBuilder<AccountSharingCubit, AccountSharingState>(
                  builder: (context, state) {
                    final isLoading = state is AccountSharingLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _sendInvitation,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 20),
                        label: Text(
                          'send_invitation'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
