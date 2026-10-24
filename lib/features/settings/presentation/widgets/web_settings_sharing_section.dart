import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/shared_accounts_coming_soon.dart';

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
                      icon: Icons.groups_outlined,
                      title: 'shared_accounts'.tr(),
                      subtitle: 'shared_accounts_description'.tr(),
                      primary: true,
                      onTap: () => showSharedAccountsComingSoon(context),
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

