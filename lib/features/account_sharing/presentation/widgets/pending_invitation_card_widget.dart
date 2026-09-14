import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class PendingInvitationCardWidget
    extends StatelessWidget {
  const PendingInvitationCardWidget({
    super.key,
    required this.email,
  });

  final String email;

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
                Colors.orange.withValues(
              alpha: 0.12,
            ),
            child: const Icon(
              Icons.hourglass_empty,
              color: Colors.orange,
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
                  Icons.hourglass_empty,
                  size: 15,
                  color: Colors.orange,
                ),
                SizedBox(width: 5.w),
                Text(
                  'pending'.tr(),
                  style: TextStyle(
                    color: Colors.orange,
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