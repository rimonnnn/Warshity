import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/app_filter_tabs.dart';
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

        return AppFilterTabs(
          items: names,
          selectedIndex: safeIndex,
          onSelected: onSelected,
          padding: EdgeInsets.zero,
          height: 42,
          spacing: 8,
          radius: 22,
        );
      },
    );
  }
}
