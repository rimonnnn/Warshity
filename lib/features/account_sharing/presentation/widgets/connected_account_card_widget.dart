import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class ConnectedAccountCardWidget
    extends StatelessWidget {
  const ConnectedAccountCardWidget({
    super.key,
    required this.email,
    this.onDelete,
    this.isDeleting = false,
  });

  final String email;
  final VoidCallback? onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
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
                Colors.green.withValues(
              alpha: 0.12,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
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
                const Icon(
                  Icons.check_circle_outline,
                  size: 15,
                  color: Colors.green,
                ),
                SizedBox(width: 5.w),
                Text(
                  'connected'.tr(),
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          trailing: isDeleting
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child:
                      const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : IconButton(
                  onPressed: onDelete,
                  tooltip: 'delete'.tr(),
                  icon: Icon(
                    Icons.delete_outline,
                    color: context.colors.error,
                  ),
                ),
        ),
      ),
    );
  }
}