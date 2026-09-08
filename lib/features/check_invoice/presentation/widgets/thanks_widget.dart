import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ThanksWidget extends StatelessWidget {
  const ThanksWidget({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: context.colors.outline.withOpacity(0.3)),
          SizedBox(height: 8),
          Icon(Icons.favorite_rounded, size: 18, color: context.colors.primary),
          SizedBox(height: 4),
          Text(
            "thank_you_for_your_business".tr(),
            style: context.text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
