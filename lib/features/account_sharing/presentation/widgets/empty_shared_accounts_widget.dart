import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptySharedAccountsWidget
    extends StatelessWidget {
  const EmptySharedAccountsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'no_accounts_to_show'.tr(),
        style: TextStyle(
          fontSize: 18.sp,
        ),
      ),
    );
  }
}