import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/theme/app_theme_extension.dart';

class InvoiceStatusBadge extends StatelessWidget {
  const InvoiceStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final semantic = context.semantic;
    final isPaid = status.toLowerCase() == 'paid';

    final fg = isPaid ? semantic.success : scheme.error;
    final bg = isPaid ? semantic.successContainer : scheme.errorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            (isPaid ? 'paid' : 'unpaid').tr(),
            style: context.text.labelLarge?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
