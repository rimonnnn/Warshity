import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';

import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';

class CategoryDropdown extends StatefulWidget {
  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.enabled = true,
  });

  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final TextEditingController _categoryController = TextEditingController();

  bool _addingCategory = false;
  bool _loading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();

    if (name.isEmpty || _loading) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final cubit = context.read<CategoriesCubit>();

      await cubit.addCategory(name);

      if (!mounted) return;

      if (cubit.state is AddCategoryError) {
        setState(() {
          _loading = false;
        });
        return;
      }

      widget.onChanged(name);

      _categoryController.clear();

      setState(() {
        _loading = false;
        _addingCategory = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  void _cancelAddCategory() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _addingCategory = false;
      _loading = false;
      _categoryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return SizedBox(
            height: 57.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CategoriesError) {
          return Text(
            state.message,
            style: TextStyle(color: context.colors.error),
          );
        }

        if (state is! CategoriesLoaded) {
          return const SizedBox();
        }

        final categories = state.categories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: widget.selectedCategory,
              isExpanded: true,

              onChanged: widget.enabled && !_addingCategory
                  ? (value) {
                      if (value == null) {
                        return;
                      }

                      if (value == '__add_category__') {
                        setState(() {
                          _addingCategory = true;
                        });

                        return;
                      }

                      widget.onChanged(value);
                    }
                  : null,

              decoration: InputDecoration(
                hintText: 'Select Category'.tr(),

                filled: true,

                fillColor: context.colors.surface,

                prefixIcon: Icon(
                  Icons.category_outlined,
                  color: context.colors.onSurfaceVariant,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),

              items: [
                ...categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name, overflow: TextOverflow.ellipsis),
                  );
                }),

                DropdownMenuItem<String>(
                  value: '__add_category__',
                  child: Row(
                    children: [
                      Icon(Icons.add, color: context.colors.primary),

                      SizedBox(width: 8.w),

                      Text(
                        'Add New Category'.tr(),
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_addingCategory) ...[
              SizedBox(height: 12.h),

              CustomTextField(
                controller: _categoryController,
                width: double.infinity,
                hint: 'Category name'.tr(),
                prefixIconData: Icons.category_outlined,
                readOnly: _loading,
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _loading ? null : _cancelAddCategory,
                      child: Text('Cancel'.tr()),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: PrimaryButtonWidget(
                      width: double.infinity,
                      height: 45.h,
                      buttonText: 'Add'.tr(),
                      isLoading: _loading,
                      onPress: _addCategory,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
