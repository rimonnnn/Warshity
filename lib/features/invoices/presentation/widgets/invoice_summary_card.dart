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

    return MergeSemantics(
      child: Semantics(
        label: '$title: $value',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
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
                      // العنوان أهدى من الرقم عشان الرقم يبقى هو الأساس
                      style: context.text.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      // borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
