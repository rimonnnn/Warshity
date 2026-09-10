import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionPressed,
    this.leading,
    this.trailing,
    this.padding,
    this.titleStyle,
    this.actionStyle,
    this.showAction = true,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;

  final Widget? leading;
  final Widget? trailing;

  final EdgeInsetsGeometry? padding;

  final TextStyle? titleStyle;
  final TextStyle? actionStyle;

  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  titleStyle ??
                  context.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          if (trailing != null) ...[SizedBox(width: 8.w), trailing!],

          if (leading != null) ...[SizedBox(width: 8.w), leading!],

          if (showAction && actionText != null) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onActionPressed,
              child: Text(
                actionText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    actionStyle ??
                    context.text.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
