import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/theme/cubit/theme_cubit.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:warshity/features/settings/presentation/cubit/settings_state.dart';
import 'package:warshity/features/settings/presentation/widgets/custom_switch_tile.dart';
import 'package:warshity/features/settings/presentation/widgets/info_item.dart';
import 'package:warshity/features/settings/presentation/widgets/logout_button.dart';
import 'package:warshity/features/settings/presentation/widgets/settings_section.dart';
import 'package:warshity/features/settings/presentation/widgets/settings_tile.dart';
import 'package:warshity/features/settings/presentation/widgets/version_card.dart';

class MobileSettingsScreen extends StatefulWidget {
  const MobileSettingsScreen({super.key});

  @override
  State<MobileSettingsScreen> createState() => _MobileSettingsScreenState();
}

class _MobileSettingsScreenState extends State<MobileSettingsScreen> {
  bool autoSync = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("settings1".tr()),
        actions: [
          IconButton(
            onPressed: () {
              context.pushReplacement(AppRoutes.mainScreen);
            },
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),

        child: Column(
          children: [
            // =====================================================
            // STORE INFORMATION
            // =====================================================
            SettingsSection(
              title: "store_information".tr(),

              children: [
                InfoItem(
                  title: "store_name".tr(),
                  value: "wershity".tr(),
                  icon: Icons.store_outlined,
                ),

                InfoItem(
                  title: "phone".tr(),
                  value: "01012345678",
                  icon: Icons.phone_outlined,
                ),

                InfoItem(
                  title: "address".tr(),
                  value: "city".tr(),
                  icon: Icons.location_on_outlined,
                  showDivider: false,
                ),
              ],
            ),

            HeightSpace(20.h),

            // =====================================================
            // SYNC
            // =====================================================
            SettingsSection(
              title: "sync_connection".tr(),

              children: [
                InfoItem(
                  title: "last_sync".tr(),
                  value: "times".tr(),
                  icon: Icons.cloud_done_outlined,
                ),

                CustomSwitchTile(
                  title: "auto_sync".tr(),
                  subtitle: "auto_sync_desc".tr(),
                  value: autoSync,

                  onChanged: (value) {
                    setState(() {
                      autoSync = value;
                    });
                  },

                  showDivider: false,
                ),

                Padding(
                  padding: EdgeInsets.all(16.sp),

                  child: SizedBox(
                    width: double.infinity,

                    child: FilledButton.icon(
                      onPressed: () {},

                      icon: const Icon(Icons.sync),

                      label: Text("sync_now".tr()),
                    ),
                  ),
                ),
              ],
            ),

            HeightSpace(20.h),

            // =====================================================
            // SECURITY
            // =====================================================
            SettingsSection(
              title: "security".tr(),

              children: [
                SettingsTile(
                  title: "change_password".tr(),
                  icon: Icons.lock_outline,
                  onTap: () {},
                ),

                SettingsTile(
                  title: "printer_settings".tr(),
                  icon: Icons.print_outlined,
                  onTap: () {},
                ),

                // =================================================
                // LANGUAGE
                // =================================================
                SettingsTile(
                  title: "language".tr(),
                  icon: Icons.language_outlined,
                  onTap: () {},
                  showDivider: true,

                  trailing: TextButton(
                    onPressed: () {
                      final newLocale = context.locale.languageCode == 'en'
                          ? const Locale('ar')
                          : const Locale('en');

                      context.push(AppRoutes.splashScreen, extra: newLocale);
                    },

                    child: Text(
                      context.locale.languageCode == "en"
                          ? "English"
                          : "العربية",

                      style: TextStyle(color: context.colors.primary),
                    ),
                  ),
                ),

                // =================================================
                // THEME
                // =================================================
                SettingsTile(
                  title: "theme".tr(),

                  icon: isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,

                  showDivider: false,

                  trailing: IconButton(
                    icon: Icon(
                      isDark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,

                      color: context.colors.primary,
                    ),

                    onPressed: () {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                ),
              ],
            ),

            HeightSpace(20.h),

            // =====================================================
            // APP INFORMATION
            // =====================================================
            VersionCard(
              image: AppAssets.logo,
              title: "wershity".tr(),
              version: "version".tr(),
            ),

            HeightSpace(20.h),

            // =====================================================
            // LOGOUT
            // =====================================================
            BlocConsumer<SettingsCubit, SettingsState>(
              listener: (context, state) {
                if (state is SettingsError) {
                  showAnimatedSnackDialog(
                    context,
                    message: state.message,
                    type: AnimatedSnackBarType.error,
                  );
                }

                if (state is SettingsSuccess) {
                  showAnimatedSnackDialog(
                    context,
                    message: state.message,
                    type: AnimatedSnackBarType.success,
                  );
                  context.goNamed(AppRoutes.loginScreen);
                }
              },

              builder: (context, state) {
                if (state is SettingsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return LogoutButton(
                  title: "logout".tr(),

                  isLoading: state is SettingsLoading,

                  onPressed: () {
                    context.read<SettingsCubit>().logOut();
                  },
                );
              },
            ),

            HeightSpace(30.h),
          ],
        ),
      ),
    );
  }
}
