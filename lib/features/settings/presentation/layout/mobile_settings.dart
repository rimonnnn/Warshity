import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/theme/cubit/theme_cubit.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/received_invitations_bottom_sheet.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/send_invitation_bottom_sheet.dart';
import 'package:warshity/features/account_sharing/presentation/screens/shared_accounts_screen.dart';

import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';

import 'package:warshity/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:warshity/features/settings/presentation/cubit/settings_state.dart';
import 'package:warshity/features/settings/presentation/widgets/change_password_bottom_sheet.dart';
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

  void _openSendInvitation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<AccountSharingCubit>(),
          child: const SendInvitationBottomSheet(),
        );
      },
    );
  }

  void _openReceivedInvitations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<AccountSharingCubit>(),
          child: const ReceivedInvitationsBottomSheet(),
        );
      },
    );
  }

  void _openSharedAccounts() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return BlocProvider(
            create: (_) => getIt<AccountSharingCubit>(),
            child: const SharedAccountsScreen(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text("settings1".tr())),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),

        child: Column(
          children: [
            SettingsSection(
              title: "store_information".tr(),

              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    String shopName = 'wershity'.tr();

                    if (authState is UserLoaded) {
                      shopName = authState.user.shopName;
                      shopName = shopName.isEmpty ? 'wershity'.tr() : shopName;
                    }

                    return InfoItem(
                      title: "store_name".tr(),
                      value: shopName,
                      icon: Icons.store_outlined,
                    );
                  },
                ),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    String activity = 'trades'.tr();

                    if (authState is UserLoaded) {
                      activity = authState.user.activity;
                    }

                    return InfoItem(
                      title: "activity".tr(),
                      value: activity,
                      icon: Icons.location_on_outlined,
                      showDivider: false,
                    );
                  },
                ),
              ],
            ),

            HeightSpace(20.h),

            HeightSpace(20.h),

            SettingsSection(
              title: "security".tr(),

              children: [
                SettingsTile(
                  title: "change_password".tr(),
                  icon: Icons.lock_outline,
                  onTap: () {
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
                  },
                ),

                // إرسال دعوة
                SettingsTile(
                  title: "share_account".tr(),
                  icon: Icons.share_outlined,
                  onTap: _openSendInvitation,
                ),

                // الدعوات الواردة
                SettingsTile(
                  title: "account_invitations".tr(),
                  icon: Icons.mail_outline,
                  onTap: _openReceivedInvitations,
                ),

                // الحسابات المشتركة
                SettingsTile(
                  title: "shared_accounts".tr(),
                  icon: Icons.people_outline,
                  onTap: _openSharedAccounts,
                ),

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

            VersionCard(
              image: AppAssets.logo,
              title: "masiter".tr(),
              version: "version".tr(),
            ),

            HeightSpace(20.h),

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
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: Text("logout".tr()),

                          content: Text("logout_confirmation".tr()),

                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },

                              child: Text(
                                "cancel".tr(),
                                style: TextStyle(
                                  color: context.colors.primary,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(80.w, 40.h),
                                backgroundColor: context.colors.error,
                              ),

                              onPressed: () {
                                Navigator.of(dialogContext).pop();

                                context.read<SettingsCubit>().logOut();
                              },

                              child: const Text(
                                "logout",
                                style: TextStyle(color: Colors.white),
                              ).tr(),
                            ),
                          ],
                        );
                      },
                    );
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
