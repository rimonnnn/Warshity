import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';

import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class ReceivedInvitationsBottomSheet extends StatelessWidget {
  const ReceivedInvitationsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return BlocListener<AccountSharingCubit, AccountSharingState>(
      listener: (context, state) async {
        if (state is AccountSharingError) {
          showAnimatedSnackDialog(
            context,
            message: state.message,
            type: AnimatedSnackBarType.error,
          );
        }

        if (state is AccountInvitationAccepted) {
          if (!context.mounted) return;

          Navigator.of(context).pop();

          if (!context.mounted) return;

          context.goNamed(AppRoutes.splashScreen);
        }

        if (state is AccountInvitationRejected) {
          if (!context.mounted) return;

          Navigator.of(context).pop();
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 560,
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
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
                          Icons.mail_outline_rounded,
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
                              'account_invitations'.tr(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              'account_invitations_description'.tr(),
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

                  const SizedBox(height: 26),

                  Expanded(
                    child: StreamBuilder<List<ShareInvitationModel>>(
                      stream: context
                          .read<AccountSharingCubit>()
                          .watchReceivedInvitations(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colors.primary,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: colors.error,
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    'something_went_wrong'.tr(),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final invitations = snapshot.data ?? [];

                        if (invitations.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(
                                        alpha: 0.10,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.mark_email_read_outlined,
                                      size: 36,
                                      color: colors.primary,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    'no_pending_invitations'.tr(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    'no_invitations_description'.tr(),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withValues(alpha: 0.60),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: invitations.length,
                          separatorBuilder: (_, __) {
                            return const SizedBox(height: 12);
                          },
                          itemBuilder: (context, index) {
                            return _InvitationCard(
                              invitation: invitations[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});

  final ShareInvitationModel invitation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: colors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'account_share_request'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      invitation.fromEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'account_share_invitation_description'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.70),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AccountSharingCubit>().respondToInvitation(
                      invitationId: invitation.id,
                      accept: false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.65),
                    ),
                    foregroundColor: colors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'reject'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<AccountSharingCubit>().respondToInvitation(
                      invitationId: invitation.id,
                      accept: true,
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'accept'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
