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
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 860;

          final filterTabs = AppFilterTabs(
            items: filters,
            selectedIndex: selectedIndex,
            onSelected: onFilterSelected,
            padding: EdgeInsets.zero,
            height: 38,
            spacing: 6,
            radius: 9,
          );

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
                filterTabs,
              ],
            );
          }

          return Row(
            children: [
              // السيرش بعرض أقصى بدل ما يتمدد
              Flexible(
                flex: 10,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: ProductSearchWidget(
                    controller: controller,
                    hintText: 'search_client'.tr(),
                    onChanged: onSearch,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // الفراغ ده بيزق الفلاتر لآخر اليمين
              const Spacer(),
              Flexible(
                flex: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.55,
                  ),
                  child: filterTabs,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
