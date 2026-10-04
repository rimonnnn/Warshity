import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';
import 'package:warshity/features/settings/presentation/widgets/change_password_bottom_sheet.dart';

import 'web_settings_rows.dart';
import 'web_settings_shared_widgets.dart';

class StoreAndSecuritySection extends StatelessWidget {
  const StoreAndSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsPageHeader(
            title: 'store_information'.tr(),
            subtitle: 'settings1'.tr(),
            icon: Icons.store_outlined,
          ),

          const SizedBox(height: 20),

          SettingsContentCard(
            title: 'store_information'.tr(),
            icon: Icons.store_outlined,
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                String shopName = 'wershity'.tr();
                String activity = 'trades'.tr();

                if (authState is UserLoaded) {
                  shopName = authState.user.shopName.isEmpty
                      ? 'wershity'.tr()
                      : authState.user.shopName;

                  activity = authState.user.activity;
                }

                return Column(
                  children: [
                    SettingsInfoRow(
                      icon: Icons.store_outlined,
                      title: 'store_name'.tr(),
                      value: shopName,
                    ),

                    const SizedBox(height: 12),

                    SettingsInfoRow(
                      icon: Icons.location_on_outlined,
                      title: 'activity'.tr(),
                      value: activity,
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          SettingsContentCard(
            title: 'change_password'.tr(),
            icon: Icons.lock_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'change_password_description'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: 380,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      _openChangePassword(context);
                    },
                    icon: const Icon(
                      Icons.lock_outline,
                    ),
                    label: Text(
                      'change_password'.tr(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openChangePassword(
    BuildContext context,
  ) {
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