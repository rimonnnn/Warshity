import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

/// Page level error UI: a friendly message plus an optional retry action.
///
/// It never renders raw exception text, the caller passes the already mapped
/// message (see `AppFailure.map`).
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: compact ? 36 : 44,
              color: colors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('retry'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
