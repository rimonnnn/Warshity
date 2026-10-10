import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';

class PrintAndShareInvoice extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onPrint;

  const PrintAndShareInvoice({
    super.key,
    required this.onShare,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: scheme.primary),
              foregroundColor: scheme.primary,
              // نفس ارتفاع وشكل زر المشاركة جنبه
              minimumSize: Size(0, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: onPrint,
            icon: const Icon(Icons.print),
            label: Text('print'.tr()),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PrimaryButtonWidget(
            height: 52.h,
            buttonColor: scheme.primary,
            buttonText: "share".tr(),
            // onPrimary بدل Colors.white: نص غامق فوق الـ teal الفاتح في الـ dark
            textColor: scheme.onPrimary,
            fontSize: 14.sp,
            iconeColor: scheme.onPrimary,
            iconSize: 18.sp,
            iconData: Icons.share,
            borderRadius: AppRadius.sm,
            onPress: onShare,
          ),
        ),
      ],
    );
  }
}
