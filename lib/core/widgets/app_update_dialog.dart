import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_update_service.dart';

Future<void> showAppUpdateDialog(
  BuildContext context,
  AppUpdateInfo update,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('update_dialog.title'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('update_dialog.description'.tr()),
              const SizedBox(height: 12),
              Text(
                'update_dialog.latest_version'.tr(args: [update.latestVersion]),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (update.releaseNotes.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'update_dialog.whats_new'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: SingleChildScrollView(
                    child: Text(update.releaseNotes),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text('update_dialog.later'.tr()),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final uri = Uri.tryParse(update.apkUrl);

                if (uri == null ||
                    uri.scheme != 'https' ||
                    uri.host != 'github.com') {
                  return;
                }

                final opened = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );

                if (opened && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              } catch (_) {
                // Keep the dialog open if opening the link fails.
              }
            },
            child: Text('update_dialog.update_now'.tr()),
          ),
        ],
      );
    },
  );
}
