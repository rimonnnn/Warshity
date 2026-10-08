import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/screens/shared_accounts_screen.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/received_invitations_bottom_sheet.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/send_invitation_bottom_sheet.dart';

import 'web_settings_shared_widgets.dart';

class AccountSharingSection extends StatelessWidget {
  const AccountSharingSection({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsPageHeader(
                title: 'share_account'.tr(),
                subtitle: 'account_sharing_description'.tr(),
                icon: Icons.share_outlined,
              ),
              const SizedBox(height: 28),
              SettingsContentCard(
                title: 'share_account'.tr(),
                icon: Icons.people_alt_outlined,
                child: Column(
                  children: [
                    _AccountActionTile(
                      icon: Icons.person_add_alt_1_outlined,
                      title: 'share_account'.tr(),
                      subtitle: 'share_account_description'.tr(),
                      primary: true,
                      onTap: () => _openSendInvitation(context),
                    ),
                    const SizedBox(height: 12),
                    _AccountActionTile(
                      icon: Icons.mark_email_unread_outlined,
                      title: 'account_invitations'.tr(),
                      subtitle: 'account_invitations_description'.tr(),
                      onTap: () => _openReceivedInvitations(context),
                    ),
                    const SizedBox(height: 12),
                    _AccountActionTile(
                      icon: Icons.groups_outlined,
                      title: 'shared_accounts'.tr(),
                      subtitle: 'shared_accounts_description'.tr(),
                      onTap: () => _openSharedAccounts(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSendInvitation(BuildContext context) {
    final cubit = getIt<AccountSharingCubit>();
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: const _SettingsDialog(child: SendInvitationBottomSheet()),
        );
      },
    );
  }

  void _openReceivedInvitations(BuildContext context) {
    final cubit = getIt<AccountSharingCubit>();
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: const _SettingsDialog(child: ReceivedInvitationsBottomSheet()),
        );
      },
    );
  }

  void _openSharedAccounts(BuildContext context) {
    final cubit = getIt<AccountSharingCubit>();
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: const _SettingsDialog(
            maxWidth: 760,
            child: SharedAccountsScreen(),
          ),
        );
      },
    );
  }
}

class _AccountActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;
  const _AccountActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });
  @override
  State<_AccountActionTile> createState() => _AccountActionTileState();
}

class _AccountActionTileState extends State<_AccountActionTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final backgroundColor = widget.primary
        ? colors.primary.withValues(alpha: 0.07)
        : (_hovered
              ? theme.colorScheme.surfaceContainerLow
              : theme.colorScheme.surface);
    final borderColor = widget.primary
        ? colors.primary.withValues(alpha: 0.22)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.55);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.primary
                        ? colors.primary.withValues(alpha: 0.12)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 21,
                    color: widget.primary
                        ? colors.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _hovered
                        ? colors.primary.withValues(alpha: 0.10)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: _hovered
                        ? colors.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const _SettingsDialog({required this.child, this.maxWidth = 500});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Material(color: theme.colorScheme.surface, child: child),
      ),
    );
  }
}
