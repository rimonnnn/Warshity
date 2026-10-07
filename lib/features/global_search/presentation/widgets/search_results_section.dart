import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/global_search/data/model/global_search_result.dart';
import 'package:warshity/features/global_search/presentation/widgets/search_result_tile.dart';

class SearchResultsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<GlobalSearchResult> results;
  final ValueChanged<GlobalSearchResult> onTap;

  const SearchResultsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.results,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: title,
          icon: icon,
        ),

        ...results.take(5).map(
          (result) => SearchResultTile(
            result: result,
            onTap: () => onTap(result),
          ),
        ),

        if (results.length > 5)
          _ViewAllButton(),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: context.colors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: context.text.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () {
            // TODO: Open full search screen.
          },
          child: Text(
            'view_all'.tr(),
          ),
        ),
      ),
    );
  }
}