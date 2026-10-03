import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class AccountHistoryCardWidget
    extends StatelessWidget {
  const AccountHistoryCardWidget({
    super.key,
    required this.email,
    required this.status,
  });

  final String email;
  final String status;

  bool get isRejected =>
      status == 'rejected';

  @override
  Widget build(BuildContext context) {
    final color = isRejected
        ? context.colors.error
        : context.colors.onSurfaceVariant;

    final icon = isRejected
        ? Icons.cancel_outlined
        : Icons.link_off_outlined;

    final text = isRejected
        ? 'rejected'.tr()
        : 'disconnected'.tr();

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
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
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
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        text,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}