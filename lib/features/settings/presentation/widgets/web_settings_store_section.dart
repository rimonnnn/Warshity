import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';
import 'package:warshity/features/settings/presentation/widgets/change_password_bottom_sheet.dart';

import 'web_settings_shared_widgets.dart';

class StoreAndSecuritySection extends StatelessWidget {
  const StoreAndSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsPageHeader(
                title: 'store_information'.tr(),
                subtitle: 'manage_store_and_security'.tr(),
                icon: Icons.store_outlined,
              ),

              const SizedBox(height: 28),

              _buildStoreInformationCard(context, theme, colors),

              const SizedBox(height: 20),

              _buildSecurityCard(context, theme, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInformationCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return SettingsContentCard(
      title: 'store_information'.tr(),
      icon: Icons.store_outlined,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          String shopName = 'masiter'.tr();
          String activity = 'trades'.tr();

          if (authState is UserLoaded) {
            shopName = authState.user.shopName.isEmpty
                ? 'masiter'.tr()
                : authState.user.shopName;

            activity = authState.user.activity.isEmpty
                ? 'trades'.tr()
                : authState.user.activity;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 650;

              if (isCompact) {
                return Column(
                  children: [
                    _buildInfoTile(
                      context: context,
                      icon: Icons.store_outlined,
                      title: 'store_name'.tr(),
                      value: shopName,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      context: context,
                      icon: Icons.business_outlined,
                      title: 'activity'.tr(),
                      value: activity,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      context: context,
                      icon: Icons.store_outlined,
                      title: 'store_name'.tr(),
                      value: shopName,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoTile(
                      context: context,
                      icon: Icons.business_outlined,
                      title: 'activity'.tr(),
                      value: activity,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return SettingsContentCard(
      title: 'change_password'.tr(),
      icon: Icons.lock_outline,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;

          final description = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'change_password_description'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                if (isCompact) const SizedBox(height: 18),
              ],
            ),
          );

          final button = FilledButton.icon(
            onPressed: () => _openChangePassword(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size(190, 46),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            icon: const Icon(Icons.lock_reset_outlined, size: 19),
            label: Text('change_password'.tr()),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                description,
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: button,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [description, const SizedBox(width: 32), button],
          );
        },
      ),
    );
  }

  void _openChangePassword(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: authCubit,
          child: const ChangePasswordBottomSheet(),
        );
      },
    );
  }
}
