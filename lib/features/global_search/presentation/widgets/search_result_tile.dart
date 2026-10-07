import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/global_search/data/model/global_search_result.dart';

class SearchResultTile extends StatelessWidget {
  final GlobalSearchResult result;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  IconData get _icon {
    switch (result.type) {
      case GlobalSearchResultType.client:
        return Icons.person_outline;

      case GlobalSearchResultType.product:
        return Icons.inventory_2_outlined;

      case GlobalSearchResultType.invoice:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            _ResultIcon(
              icon: _icon,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _ResultContent(
                title: result.title,
                subtitle: result.subtitle,
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: 18,
              color: context.colors.onSurface.withValues(
                alpha: .5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  final IconData icon;

  const _ResultIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(
          alpha: .08,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 18,
        color: context.colors.primary,
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _ResultContent({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        if (subtitle != null && subtitle!.isNotEmpty)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(
                alpha: .60,
              ),
            ),
          ),
      ],
    );
  }
}