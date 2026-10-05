import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/home/data/recent_operation_model.dart';

class RecentOperationsTableWeb extends StatelessWidget {
  const RecentOperationsTableWeb({
    super.key,
    required this.operations,
    this.onItemTap,
    this.borderRadius,
  });

  final List<RecentOperationModel> operations;
  final void Function(int index)? onItemTap;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        children: [
          const _TableHeader(),

          if (operations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'no_recent_operations'.tr(),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < operations.length; i++) ...[
              if (i != 0)
                Divider(height: 1, color: context.colors.outlineVariant),
              _TableRow(
                operation: operations[i],
                onTap: () => onItemTap?.call(i),
              ),
            ],
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return Container(
      color: context.colors.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text('operation_customer'.tr(), style: style),
          ),
          Expanded(
            flex: 3,
            child: Text('operation_date'.tr(), style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'operation_amount'.tr(),
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.operation, this.onTap});

  final RecentOperationModel operation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = operation.customerName.trim();
    final initial = name.isEmpty ? '?' : name.characters.first;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xffD8F0A7),
                    child:
                        operation.avatar ??
                        Text(
                          initial,
                          style: const TextStyle(
                            color: Color(0xff5B7F22),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      operation.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 3,
              child: Text(
                operation.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                operation.price,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}