import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';

class InvoiceHistoryHeader extends StatelessWidget {
  const InvoiceHistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'invoice_history'.tr(),
            style: context.text.headlineSmall?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IntrinsicWidth(
          child: ElevatedButton.icon(
            onPressed: () => context.pushNamed(AppRoutes.addInvoicesScreen),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 48), // يلغي infinity من الـ theme
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'add_invoice'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
