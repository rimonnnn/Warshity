import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class ProductsPagination extends StatelessWidget {
  const ProductsPagination({
    super.key,
    required this.page,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  final int page;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final start = ((page - 1) * itemsPerPage) + 1;

    final end = (page * itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Text(
            'showing_items'.tr(args: ['$start', '$end', '$totalItems']),
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const Spacer(),

          IconButton(
            onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),

          ...List.generate(totalPages, (index) {
            final pageNumber = index + 1;
            final selected = pageNumber == page;

            if (totalPages > 7 &&
                (pageNumber > 3 && pageNumber < totalPages - 2) &&
                pageNumber != page) {
              if (pageNumber == 4) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...'),
                );
              }

              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => onPageChanged(pageNumber),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pageNumber',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? context.colors.onPrimary : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),

          IconButton(
            onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
