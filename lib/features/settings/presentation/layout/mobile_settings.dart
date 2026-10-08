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
import 'package:warshity/features/account_sharing/presentation/screens/shared_accounts_screen.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/received_invitations_bottom_sheet.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/send_invitation_bottom_sheet.dart';
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
        return BlocProvider.value(
          value: getIt<AccountSharingCubit>(),
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
        return BlocProvider.value(
          value: getIt<AccountSharingCubit>(),
          child: const ReceivedInvitationsBottomSheet(),
        );
      },
    );
  }

  void _openSharedAccounts() {
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

  void _openChangePassword() {
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

  // نفس منطق تبديل اللغة اللي كان جوه الـ TextButton، بس بقى متاح للصف كله
  void _toggleLanguage() {
    final newLocale = context.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    context.goNamed(AppRoutes.splashScreen, extra: newLocale);
  }

  void _toggleTheme() {
    context.read<ThemeCubit>().toggleTheme();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final scheme = dialogContext.colors;

        return AlertDialog(
          title: Text("logout".tr()),
          content: Text("logout_confirmation".tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text("cancel".tr()),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(80.w, 40.h),
                backgroundColor: scheme.error,
                // onError بدل Colors.white: التباين الصح فوق الأحمر في الـ dark والـ light
                foregroundColor: scheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                context.read<SettingsCubit>().logOut();
              },
              child: Text("logout".tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text("settings1".tr())),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------- STORE INFO ----------------
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
                      // كانت location_on: النشاط مش موقع
                      icon: Icons.work_outline,
                      showDivider: false,
                    );
                  },
                ),
              ],
            ),

            HeightSpace(20.h),

            // ---------------- ACCOUNT & SHARING ----------------
            SettingsSection(
              title: "security".tr(),

              children: [
                SettingsTile(
                  title: "change_password".tr(),
                  icon: Icons.lock_outline,
                  onTap: _openChangePassword,
                ),

                SettingsTile(
                  title: "share_account".tr(),
                  icon: Icons.share_outlined,
                  onTap: _openSendInvitation,
                ),

                SettingsTile(
                  title: "account_invitations".tr(),
                  icon: Icons.mail_outline,
                  onTap: _openReceivedInvitations,
                ),

                SettingsTile(
                  title: "shared_accounts".tr(),
                  icon: Icons.people_outline,
                  onTap: _openSharedAccounts,
                  showDivider: false,
                ),
              ],
            ),

            HeightSpace(20.h),

            // ---------------- PREFERENCES ----------------
            // اللغة والـ theme كانوا جوه قسم الأمان، فاتنقلوا لقسم تفضيلات.
            // ضيف المفتاح 'preferences' في ar.json (التفضيلات) و en.json (Preferences)
            SettingsSection(
              title: "preferences".tr(),

              children: [
                SettingsTile(
                  title: "language".tr(),
                  icon: Icons.language_outlined,
                  // الصف كله بقى قابل للضغط، بدل زر صغير في الطرف
                  onTap: _toggleLanguage,
                  showDivider: true,

                  trailing: Text(
                    context.locale.languageCode == "en" ? "English" : "العربية",
                    style: context.text.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SettingsTile(
                  title: "theme".tr(),

                  icon: isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,

                  onTap: _toggleTheme,
                  showDivider: false,

                  // Switch بدل IconButton: حالة الـ theme واضحة من غير ما تخمّن
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => _toggleTheme(),
                  ),
                ),
              ],
            ),

            HeightSpace(20.h),

            // ---------------- ABOUT ----------------
            VersionCard(
              image: AppAssets.logo,
              title: "masiter".tr(),
              version: 'version'.tr(),
            ),

            HeightSpace(24.h),

            // ---------------- LOGOUT ----------------
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
                  // ارتفاع ثابت بدل ما الصفحة تقفز لما الزر يتبدل بالـ spinner
                  return SizedBox(
                    height: 56.h,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                return LogoutButton(
                  title: "logout".tr(),

                  isLoading: state is SettingsLoading,

                  onPressed: _confirmLogout,
                );
              },
            ),

            // مسافة سفلية تحترم الـ gesture bar وأي bottom nav
            SizedBox(height: 30.h + MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}
