import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({
    super.key,
    required this.isOnline,
    required this.lastSync,
    required this.onChanged,
    required this.onSyncPressed,
    this.backgroundColor,
    this.borderRadius,
  });

  final bool isOnline;
  final String lastSync;

  final ValueChanged<bool> onChanged;
  final VoidCallback onSyncPressed;

  final Color? backgroundColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppRadius.lg,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "sync_connection".tr(),
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_done_outlined,
                    color: Colors.green,
                    size: 18.sp,
                  ),

                  SizedBox(width: 8.w),

                  Expanded(
                    child: Text(
                      lastSync,
                      textAlign: TextAlign.end,
                      style: context.text.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            Row(
              children: [
                Switch(
                  value: isOnline,
                  onChanged: onChanged,
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    "auto_sync".tr(),
                    textAlign: TextAlign.end,
                    style: context.text.bodyMedium,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSyncPressed,
                child: Text("sync_now".tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}