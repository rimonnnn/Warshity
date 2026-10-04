import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';

class ProductsCategories extends StatelessWidget {
  const ProductsCategories({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const SizedBox(
            height: 45,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CategoriesError) {
          return Text(
            state.message,
            style: TextStyle(color: context.colors.error),
          );
        }

        if (state is! CategoriesLoaded) {
          return const SizedBox.shrink();
        }

        final names = [
          'all'.tr(),
          ...state.categories.map((category) => category.name),
        ];

        final safeIndex = selectedIndex >= 0 && selectedIndex < names.length
            ? selectedIndex
            : 0;

        return SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: names.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = index == safeIndex;

              return InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colors.primary
                        : context.colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : context.colors.outlineVariant,
                    ),
                  ),
                  child: Text(
                    names[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? context.colors.onPrimary : null,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
