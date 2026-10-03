import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';

/// Shows a confirmation dialog. Returns `true` if the user confirmed.
Future<bool> showDeleteSharedAccountDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('delete_shared_account'.tr()),
        content: Text('delete_shared_account_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: context.colors.primary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  return confirmed == true;
}
