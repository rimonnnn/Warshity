import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'shared_account_status_widget.dart';

class SharedAccountCardWidget extends StatelessWidget {
  const SharedAccountCardWidget({
    super.key,
    required this.email,
    required this.status,
    required this.isCurrentSharedAccount,
    required this.isDeleting,
    this.onDelete,
  });

  final String email;
  final String status;
  final bool isCurrentSharedAccount;
  final bool isDeleting;
  final VoidCallback? onDelete;

  Color _getStatusColor(BuildContext context) {
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

  IconData _getStatusIcon() {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: statusColor.withValues(
              alpha: 0.12,
            ),
            child: Icon(
              _getStatusIcon(),
              color: statusColor,
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
            padding: EdgeInsets.only(top: 5.h),
            child: SharedAccountStatusWidget(
              status: status,
            ),
          ),
          trailing: status == 'accepted' &&
                  isCurrentSharedAccount
              ? isDeleting
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: context.colors.error,
                      ),
                      tooltip: 'delete'.tr(),
                    )
              : null,
        ),
      ),
    );
  }
}