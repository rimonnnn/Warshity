import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/theme/theme_cubit.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/settings/presentation/widgets/custom_switch_tile.dart';
import 'package:warshity/features/settings/presentation/widgets/info_item.dart';
import 'package:warshity/features/settings/presentation/widgets/logout_button.dart';
import 'package:warshity/features/settings/presentation/widgets/settings_section.dart';
import 'package:warshity/features/settings/presentation/widgets/settings_tile.dart';
import 'package:warshity/features/settings/presentation/widgets/version_card.dart';

class WebSettingsScreen extends StatefulWidget {
  const WebSettingsScreen({super.key});

  @override
  State<WebSettingsScreen> createState() => _WebSettingsScreenState();
}

class _WebSettingsScreenState extends State<WebSettingsScreen> {
  bool autoSync = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                /// الصف الأول
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SettingsSection(
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
                    ),

                    SizedBox(width: 24.w),

                    Expanded(
                      child: SettingsSection(
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
                    ),
                  ],
                ),

                HeightSpace(24.h),

                /// الصف الثاني
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SettingsSection(
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
                          ),
                          SettingsTile(
                            title: "language".tr(),
                            icon: Icons.language_outlined,
                            showDivider: true,
                            trailing: TextButton(
                              onPressed: () {
                                context.setLocale(
                                  context.locale == Locale("en")
                                      ? Locale("ar")
                                      : Locale("en"),
                                );
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
                            icon: Icons.palette_outlined,
                            showDivider: false,

                            trailing: IconButton(
                              icon: Icon(
                                isDark
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                color: context.colors.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  context.read<ThemeCubit>().toggleTheme();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 24.w),

                    Expanded(
                      child: VersionCard(
                        image: AppAssets.logo,
                        title: "wershity".tr(),
                        version: "version".tr(),
                      ),
                    ),
                  ],
                ),

                HeightSpace(32.h),

                Align(
                  alignment: Alignment.bottomLeft,
                  child: LogoutButton(
                    title: "logout".tr(),
                    onPressed: () {},
                    width: 400,
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
