import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/di/injection.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsPageHeader(
            title: 'share_account'.tr(),
            subtitle: 'shared_accounts'.tr(),
            icon: Icons.share_outlined,
          ),

          const SizedBox(height: 20),

          _ActionCard(
            titleKey: 'share_account',
            icon: Icons.share_outlined,
            filled: true,
            onPressed: () => _openSendInvitation(context),
          ),

          const SizedBox(height: 20),

          _ActionCard(
            titleKey: 'account_invitations',
            icon: Icons.mail_outline,
            onPressed: () => _openReceivedInvitations(context),
          ),

          const SizedBox(height: 20),

          _ActionCard(
            titleKey: 'shared_accounts',
            icon: Icons.people_outline,
            onPressed: () => _openSharedAccounts(context),
          ),
        ],
      ),
    );
  }

  void _openSendInvitation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider.value(
          value: getIt<AccountSharingCubit>(),
          child: const Center(
            child: SendInvitationBottomSheet(),
          ),
        );
      },
    );
  }

  void _openReceivedInvitations(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider.value(
          value: getIt<AccountSharingCubit>(),
          child: const Center(
            child: ReceivedInvitationsBottomSheet(),
          ),
        );
      },
    );
  }

  void _openSharedAccounts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return BlocProvider.value(
            value: getIt<AccountSharingCubit>(),
            child: const SharedAccountsScreen(),
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String titleKey;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  const _ActionCard({
    required this.titleKey,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsContentCard(
      title: titleKey.tr(),
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleKey.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: 380,
            height: 48,
            child: filled
                ? FilledButton.icon(
                    onPressed: onPressed,
                    icon: Icon(icon),
                    label: Text(titleKey.tr()),
                  )
                : OutlinedButton.icon(
                    onPressed: onPressed,
                    icon: Icon(icon),
                    label: Text(titleKey.tr()),
                  ),
          ),
        ],
      ),
    );
  }
}