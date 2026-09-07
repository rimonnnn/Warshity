import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class InvoicePopupMenuItem extends StatelessWidget {
  const InvoicePopupMenuItem({
    super.key,
    required this.onPrint,
    required this.onExport,
    required this.onDelete,
  });

  final VoidCallback onPrint;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      iconColor: context.colors.primary,
      onSelected: (value) {
        switch (value) {
          case 'print':
            onPrint();
            break;
          case 'export':
            onExport();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'print',
          child: Text('print'.tr()),
        ),
        PopupMenuItem(
          value: 'export',
          child: Text('export_pdf'.tr()),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('delete'.tr()),
        ),
      ],
    );
  }
}