import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';

class PrintAndShareInvoice extends StatelessWidget {
  final VoidCallback onSharePdf;
  final VoidCallback onPrint;
  const PrintAndShareInvoice({super.key, required this.onSharePdf, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButtonWidget(
            buttonColor: Color(0xFF394D14),
            buttonText: "print".tr(),
            textColor: Colors.white,
            fontSize: 14.sp,
            iconeColor: Colors.white,
            iconSize: 18.sp,

            iconData: Icons.print,
            onPress: onPrint,
          ),
        ),
        SizedBox(width: 12), // لو عندك spacing widget كده
        Expanded(
          child: PrimaryButtonWidget(
            buttonColor: Color(0xFF653D1E),
            buttonText: "share_pdf".tr(),
            iconSize: 18.sp,
            fontSize: 14.sp,
            textColor: Colors.white,
            iconeColor: Colors.white,
            iconData: Icons.share,
            onPress: onSharePdf,
          ),
        ),
      ],
    );
  }
}
