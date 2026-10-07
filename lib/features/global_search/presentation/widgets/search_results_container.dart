import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class SearchResultsContainer extends StatelessWidget {
  final Widget child;

  const SearchResultsContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: context.colors.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}