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
      child:Row(
  children: [
    Text(
      title,
      style: titleStyle ??
          context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ),

    if (trailing != null) ...[
      SizedBox(width: 8.w),
      trailing!,
    ],

    const Spacer(),

    if (leading != null) ...[
      leading!,
      SizedBox(width: 8.w),
    ],

    if (showAction && actionText != null)
      GestureDetector(
        onTap: onActionPressed,
        child: Text(
          actionText!,
          style: actionStyle ??
              context.text.bodyMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
  ],
)
    );
  }
}