import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:warshity/features/settings/presentation/cubit/settings_state.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
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
        final scheme = context.colors;
        final loading = state is SettingsLoading;

        // نفس الشكل الهادئ (tonal) بتاع زر الموبايل:
        // errorContainer بنص error، بدل أحمر مليان بنص أبيض
        final bg = scheme.errorContainer;
        final fg = scheme.error;

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              // وقت الـ loading الزر يفضل بلونه بدل ما يتحول لرمادي
              disabledBackgroundColor: bg,
              disabledForegroundColor: fg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: loading
                ? null
                : () {
                    _showLogoutDialog(context);
                  },
            icon: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                : const Icon(Icons.logout_outlined),
            label: Text(
              'logout'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final scheme = dialogContext.colors;

        return AlertDialog(
          title: Text('logout'.tr()),
          content: Text('logout_confirmation'.tr()),
          actions: [
            // TextButton بياخد لون primary من الـ theme، فمفيش داعي للـ style
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('cancel'.tr()),
            ),
            // زر التأكيد أحمر مليان: الخطوة الأخيرة لازم تبان إنها خطيرة
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                context.read<SettingsCubit>().logOut();
              },
              child: Text('logout'.tr()),
            ),
          ],
        );
      },
    );
  }
}
