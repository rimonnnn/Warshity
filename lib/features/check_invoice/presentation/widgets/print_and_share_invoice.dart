import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colors.primary),
              foregroundColor: context.colors.primary,
            ),
            onPressed: onPrint,
            icon: Icon(Icons.print),
            label: Text('print'.tr()),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PrimaryButtonWidget(
            buttonColor: context.colors.primary,
            buttonText: "share".tr(),
            textColor: Colors.white,
            fontSize: 14.sp,
            iconeColor: Colors.white,
            iconSize: 18.sp,
            iconData: Icons.share,
            onPress: onShare,
          ),
        ),
      ],
    );
  }
}
