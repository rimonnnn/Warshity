import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/features/global_search/data/model/global_search_result.dart';
import 'package:warshity/features/global_search/presentation/cubit/global_search_cubit.dart';
import 'package:warshity/features/global_search/presentation/cubit/global_search_state.dart';
import 'package:warshity/features/global_search/presentation/widgets/search_results_container.dart';
import 'package:warshity/features/global_search/presentation/widgets/search_results_section.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/widgets/web_product_details.dart';

class GlobalSearchResults extends StatelessWidget {
  const GlobalSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalSearchCubit, GlobalSearchState>(
      builder: (context, state) {
        if (state is GlobalSearchInitial) {
          return const SizedBox.shrink();
        }

        if (state is GlobalSearchLoading) {
          return const SearchResultsContainer(
            child: SizedBox(
              height: 90,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }

        if (state is GlobalSearchFailure) {
          return SearchResultsContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('search_error'.tr(), style: context.text.bodyMedium),
            ),
          );
        }

        if (state is! GlobalSearchSuccess) {
          return const SizedBox.shrink();
        }

        if (!state.hasResults) {
          return SearchResultsContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'no_search_results'.tr(),
                style: context.text.bodyMedium,
              ),
            ),
          );
        }

        return SearchResultsContainer(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.clients.isNotEmpty)
                    SearchResultsSection(
                      title: 'clients'.tr(),
                      icon: Icons.people_outline,
                      results: state.clients,
                      onTap: (result) {
                        _openResult(context, result);
                      },
                    ),

                  if (state.products.isNotEmpty)
                    SearchResultsSection(
                      title: 'products'.tr(),
                      icon: Icons.inventory_2_outlined,
                      results: state.products,
                      onTap: (result) {
                        _openResult(context, result);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openResult(BuildContext context, GlobalSearchResult result) {
    context.read<GlobalSearchCubit>().clear();

    switch (result.type) {
      case GlobalSearchResultType.client:
        context.push(AppRoutes.customerdetailsScreen, extra: result.id);
        break;

      case GlobalSearchResultType.product:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return BlocProvider(
                create: (_) => getIt<ProductsCubit>()..watchProducts(),
                child: WebProductDetails(productId: result.id),
              );
            },
          ),
        );
        break;
    }
  }
}
