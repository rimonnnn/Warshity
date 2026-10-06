import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/theme/cubit/theme_cubit.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/search_widget.dart';
import 'package:warshity/features/main/presentation/widgets/top_bar_button.dart';
import 'package:warshity/features/main/presentation/widgets/top_bar_icon_button.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';

class WebTopBar extends StatefulWidget {
  const WebTopBar({super.key});

  @override
  State<WebTopBar> createState() => _WebTopBarState();
}

class _WebTopBarState extends State<WebTopBar> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat.yMMMMEEEEd(
      context.locale.languageCode,
    ).format(DateTime.now());

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Builder(
      builder: (context) {
        return Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              // Search
              Expanded(
                flex: 5,
                child: CustomSearchTextField(
                  height: 36,
                  hintText: 'search1'.tr(),
                  controller: searchController,
                  onChanged: (value) {},
                ),
              ),

              const SizedBox(width: 16),

              // Current date
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(
                    alpha: .10,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentDate,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Language
              TopBarIconButton(
                icon: Icons.translate,
                onPressed: () {
                  final isArabic = context.locale.languageCode == 'ar';

                  context.setLocale(
                    isArabic ? const Locale('en') : const Locale('ar'),
                  );
                },
              ),

              const SizedBox(width: 8),

              // Theme
              TopBarIconButton(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),

              const Spacer(),

              // Actions
              Row(
                children: [
                  TopBarButton(
                    icon: Icons.add,
                    label: 'new_invoice'.tr(),
                    filled: true,
                    onPressed: () {
                      context.pushNamed(AppRoutes.addInvoicesScreen);
                    },
                  ),

                  const SizedBox(width: 10),

                  TopBarButton(
                    icon: Icons.add,
                    label: 'add_product'.tr(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) => getIt<CategoriesCubit>(),
                            ),
                            BlocProvider(
                              create: (_) => getIt<AddProductCubit>(),
                            ),
                          ],
                          child: const AddProductDialog(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
