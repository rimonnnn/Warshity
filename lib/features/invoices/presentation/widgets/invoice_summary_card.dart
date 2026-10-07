import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class InvoiceSummaryCard extends StatelessWidget {
  const InvoiceSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;

  /// لون الأيقونة وخلفيتها (ابعته من الـ theme، مش hardcoded)
  final Color color;

  /// لون الرقم. لو null بيستخدم [color]
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
