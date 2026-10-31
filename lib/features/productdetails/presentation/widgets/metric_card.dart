import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle, this.onChangePrice,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onChangePrice;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    bool isWeb = kIsWeb;
    return Container(
      constraints: const BoxConstraints(minHeight: 124),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Spacer(),
                    if (onChangePrice != null) ...[
                    SizedBox(height: 2.h),
                  IconButton(onPressed: onChangePrice, icon: Icon(Icons.edit,size: isWeb? 28 : 19.sp))
                  ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
