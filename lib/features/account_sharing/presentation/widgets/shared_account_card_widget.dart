import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'shared_account_status_widget.dart';

class SharedAccountCardWidget
    extends StatelessWidget {
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
    final statusColor =
        _getStatusColor(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                color: statusColor,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 5),

                  SharedAccountStatusWidget(
                    status: status,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            if (status == 'accepted' &&
                isCurrentSharedAccount)
              isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: context.colors.error,
                        size: 20,
                      ),
                      tooltip: 'delete'.tr(),
                    ),
          ],
        ),
      ),
    );
  }
}