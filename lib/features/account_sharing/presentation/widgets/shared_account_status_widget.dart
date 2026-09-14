import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class SharedAccountStatusWidget extends StatelessWidget {
  const SharedAccountStatusWidget({
    super.key,
    required this.status,
  });

  final String status;

  Color _getColor(BuildContext context) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return context.colors.error;
      default:
        return context.colors.onSurfaceVariant;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getText() {
    switch (status) {
      case 'accepted':
        return 'accepted'.tr();
      case 'pending':
        return 'pending'.tr();
      case 'rejected':
        return 'rejected'.tr();
      default:
        return 'unknown_status'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getIcon(),
          size: 15.sp,
          color: color,
        ),
        SizedBox(width: 5.w),
        Text(
          _getText(),
          style: TextStyle(
            color: color,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}