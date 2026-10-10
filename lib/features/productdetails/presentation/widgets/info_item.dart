import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class InfoItem extends StatelessWidget {
  const InfoItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final labelText = Text(
          label,
          softWrap: true,
          style: context.text.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        );
        final valueText = Text(
          value,
          softWrap: true,
          textAlign: TextAlign.end,
          style: context.text.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        );

        if (constraints.maxWidth < 330) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelText,
              const SizedBox(height: 4),
              valueText,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: labelText),
            const SizedBox(width: 12),
            Expanded(flex: 6, child: valueText),
          ],
        );
      },
    );
  }
}
