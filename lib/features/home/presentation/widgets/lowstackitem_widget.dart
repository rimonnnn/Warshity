import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class LowStockItem extends StatelessWidget {
  const LowStockItem({
    super.key,
    required this.productName,
    required this.remainText,
    this.buttonText,
    this.onPressed,
  });

  final String productName;
  final String remainText;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 18.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium,
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          remainText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: Size(
                        isMobile ? 90.w : 120.w,
                        44.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12.w : 18.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: FittedBox(
                      child: Text(
                        buttonText ?? "order".tr(),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
          ],
        );
      },
    );
  }
}