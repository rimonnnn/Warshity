import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class InvoicePopupMenuItem extends StatelessWidget {
  const InvoicePopupMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        PopupMenuItem(value: 'view', child: Text('view'.tr())),
        PopupMenuItem(value: 'edit', child: Text('edit'.tr())),
        PopupMenuItem(value: 'print', child: Text('print'.tr())),
        PopupMenuItem(value: 'export', child: Text('export_pdf'.tr())),
        PopupMenuItem(value: 'duplicate', child: Text('duplicate'.tr())),
        PopupMenuItem(value: 'delete', child: Text('delete'.tr())),
      ],
      iconColor: context.colors.primary,
    );
  }
}
