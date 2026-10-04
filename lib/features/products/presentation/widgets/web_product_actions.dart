import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';

class ProductsHeader extends StatelessWidget {
  const ProductsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'products'.tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'products'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductsActions extends StatelessWidget {
  const ProductsActions({
    super.key,
    required this.searchController,
    required this.categoriesCubit,
  });

  final TextEditingController searchController;
  final CategoriesCubit categoriesCubit;

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: categoriesCubit),
            BlocProvider(create: (_) => getIt<AddProductCubit>()),
          ],
          child: const AddProductDialog(
            imagecontainerheight: 250,
            productnamefieldheight: 100,
            productcodefieldheight: 100,
            sellingpricefieldheight: 100,
            currentquantityfieldheight: 100,
            savebuttonheight: 50,
            cancelbuttonheight: 50,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'search_product'.tr(),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: _border(colors.outlineVariant),
              enabledBorder: _border(colors.outlineVariant),
              focusedBorder: _border(colors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(width: 12),

        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () => _openAddDialog(context),
            icon: const Icon(Icons.add),
            label: Text('add_product'.tr()),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
