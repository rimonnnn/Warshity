import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomerHeaderCard extends StatelessWidget {
  const CustomerHeaderCard({
    super.key,
    required this.name,
    required this.phone,
    this.address,
    this.avatar,
    this.showCallButton = true,
  });

  final String name;
  final String phone;
  final String? address;
  final Widget? avatar;
  final bool showCallButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppRadius.md.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _buildAvatar(context),

          SizedBox(width: AppRadius.md.w),

          Expanded(child: _buildCustomerInfo(context, theme, colors)),

          if (showCallButton) ...[
            SizedBox(width: AppRadius.md.w),
            _buildCallButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: ClipOval(
        child: ColoredBox(
          color: colors.surfaceContainerHighest,
          child:
              avatar ??
              Icon(Icons.person_outline, color: colors.primary, size: 24.sp),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        if (address != null && address!.trim().isNotEmpty) ...[
          SizedBox(height: AppRadius.sm),
          Text(
            address!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],

        SizedBox(height: AppRadius.sm),

        Text(
          phone,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.primaryContainer,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          // Call action
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44.w,
          height: 44.w,
          child: Icon(Icons.phone_outlined, color: colors.primary, size: 21.sp),
        ),
      ),
    );
  }
}
