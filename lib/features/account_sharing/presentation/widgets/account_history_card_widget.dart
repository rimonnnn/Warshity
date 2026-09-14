import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class AccountHistoryCardWidget
    extends StatelessWidget {
  const AccountHistoryCardWidget({
    super.key,
    required this.email,
    required this.status,
  });

  final String email;
  final String status;

  bool get isRejected =>
      status == 'rejected';

  @override
  Widget build(BuildContext context) {
    final color = isRejected
        ? context.colors.error
        : context.colors.onSurfaceVariant;

    final icon = isRejected
        ? Icons.cancel_outlined
        : Icons.link_off_outlined;

    final text = isRejected
        ? 'rejected'.tr()
        : 'disconnected'.tr();

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,

          leading: CircleAvatar(
            backgroundColor:
                color.withValues(
              alpha: 0.12,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          title: Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          subtitle: Padding(
            padding: EdgeInsets.only(
              top: 5.h,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15.sp,
                  color: color,
                ),
                SizedBox(width: 5.w),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}