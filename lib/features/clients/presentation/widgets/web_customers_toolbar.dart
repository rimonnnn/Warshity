part of '../layout/web_client.dart';

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
    required this.onSearch,
  });

  final TextEditingController controller;
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 860;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProductSearchWidget(
                  controller: controller,
                  hintText: 'search_client'.tr(),
                  onChanged: onSearch,
                ),
                const SizedBox(height: 10),
                _FilterGroup(
                  filters: filters,
                  selectedIndex: selectedIndex,
                  onSelected: onFilterSelected,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: ProductSearchWidget(
                  controller: controller,
                  hintText: 'search_client'.tr(),
                  onChanged: onSearch,
                ),
              ),
              const SizedBox(width: 14),
              _FilterGroup(
                filters: filters,
                selectedIndex: selectedIndex,
                onSelected: onFilterSelected,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        filters.length,
        (index) => Padding(
          padding: EdgeInsetsDirectional.only(
            start: index == 0 ? 0 : 6,
          ),
          child: _FilterChip(
            label: filters[index],
            selected: selectedIndex == index,
            onTap: () => onSelected(index),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? context.colors.primary.withValues(alpha: .10)
        : context.colors.outlineVariant;

    final Color fillColor =
        selected ? context.colors.primary.withValues(alpha: .14) : context.colors.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(
          minWidth: 92,
          minHeight: 38,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                Icons.check_rounded,
                size: 15,
                color: context.colors.primary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? context.colors.primary
                        : context.colors.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
