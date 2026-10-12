import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
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
  static const String _addKey = '__add_category__';

  final TextEditingController _categoryController = TextEditingController();
  final bool isWeb = kIsWeb;
  bool _addingCategory = false;
  bool _loading = false;
  bool _attempted = false; // عشان ما نعرضش خطأ قديم لما الحقل يتفتح تاني

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
      _attempted = true;
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
        _attempted = false;
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
      _attempted = false;
      _categoryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final bool isWeb = kIsWeb;
    final double gap = isWeb ? 12 : 12.h;
    final double radius = AppRadius.sm;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return SizedBox(
            height: isWeb ? 57 : 57.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CategoriesError) {
          return Text(state.message, style: TextStyle(color: scheme.error));
        }

        // الـ dropdown لازم يفضل ظاهر وقت الإضافة وعند خطأ الإضافة
        final categories = switch (state) {
          CategoriesLoaded(:final categories) => categories,
          AddCategoryLoading(:final categories) => categories,
          AddCategoryError(:final categories) => categories,
          _ => null,
        };

        if (categories == null) {
          return const SizedBox();
        }

        final names = categories.map((c) => c.name).toList();

        // يمنع assertion لو القيمة لسه مش في القايمة
        final String? safeValue = names.contains(widget.selectedCategory)
            ? widget.selectedCategory
            : null;

        final String? addError = state is AddCategoryError
            ? state.message
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: safeValue,
              isExpanded: true,
              borderRadius: BorderRadius.circular(radius),
              dropdownColor: scheme.surfaceContainerHigh,

              onChanged: widget.enabled && !_addingCategory
                  ? (value) {
                      if (value == null) {
                        return;
                      }

                      if (value == _addKey) {
                        setState(() {
                          _addingCategory = true;
                          _attempted = false;
                        });

                        return;
                      }

                      widget.onChanged(value);
                    }
                  : null,

              decoration: InputDecoration(
                hintText: 'Select Category'.tr(),
                hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                filled: true,
                fillColor: scheme.surface,
                prefixIcon: Icon(
                  Icons.category_outlined,
                  
                  color: context.colors.onSurfaceVariant,
                  size: isWeb ? 18 : 20.sp,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                
                enabledBorder: border(scheme.outlineVariant),
                disabledBorder: border(scheme.outlineVariant),
                focusedBorder: border(scheme.primary, width: 1.5),
              ),

              items: [
                ...categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name, overflow: TextOverflow.ellipsis),
                  );
                }),

                DropdownMenuItem<String>(
                  value: _addKey,
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, color: scheme.primary),
                      Icon(
                        Icons.add,
                        color: context.colors.primary,
                        size: isWeb ? 18 : 20.sp,
                      ),

                      SizedBox(width: isWeb ? 8 : 8.w),

                      Text(
                        'Add New Category'.tr(),
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_addingCategory) ...[
              SizedBox(height: gap),

              CustomTextField(
                controller: _categoryController,
                width: double.infinity,
                hint: 'Category name'.tr(),
                prefixIconData: Icons.category_outlined,
                iconSize: isWeb ? 18 : 20.sp,
                readOnly: _loading,
              ),

              if (_attempted && addError != null) ...[
                SizedBox(height: isWeb ? 6 : 6.h),
                Text(
                  addError.tr(),
                  style: context.text.bodySmall?.copyWith(color: scheme.error),
                ),
              ],

              SizedBox(height: gap),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _cancelAddCategory,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, isWeb ? 45 : 45.h),
                        foregroundColor: scheme.onSurface,
                        side: BorderSide(color: scheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                      ),
                      child: Text('Cancel'.tr()),
                    ),
                  ),

                  SizedBox(width: isWeb ? 10 : 10.w),

                  Expanded(
                    child: PrimaryButtonWidget(
                      width: double.infinity,
                      height: isWeb ? 45 : 45.h,
                    
                      fontSize: isWeb ? 20 : 16.sp,
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
