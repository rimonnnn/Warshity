import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.selectedItem,
    this.onSelected,
    this.prefixIcon,
    this.width,
    this.height,
    this.borderRadius,
    this.validator,
    this.onAddCategory,
  });

  final String label;
  final String hint;
  final List<String> items;
  final String? selectedItem;
  final String? prefixIcon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final void Function(String?)? onSelected;
  final String? Function(String?)? validator;
  final Future<void> Function(String categoryName)? onAddCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: width ?? 330.w,
          height: height ?? 60.h,
          child: DropdownSearch<String>(
            items: (filter, infiniteScrollProps) {
              return items;
            },

            selectedItem: selectedItem,

            onSelected: onSelected,

            validator: validator,

            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: hint,

                prefixIcon: prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(prefixIcon!, width: 24, height: 24),
                      )
                    : null,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),

                filled: true,

                fillColor: Theme.of(context).colorScheme.surface,

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppRadius.sm,
                  ),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppRadius.sm,
                  ),
                  borderSide: const BorderSide(
                    color: Color(0xffC67A3D),
                    width: 1.5,
                  ),
                ),

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppRadius.sm,
                  ),
                  borderSide: const BorderSide(color: Colors.red),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppRadius.sm,
                  ),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),

            popupProps: PopupProps.menu(
              showSearchBox: true,

              fit: FlexFit.loose,

              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),

              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "search".tr(),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),

                  suffixIcon: onAddCategory != null
                      ? IconButton(
                          tooltip: 'add_new_category'.tr(),

                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),

                          onPressed: () async {
                            Navigator.of(context).pop();

                            await Future.delayed(
                              const Duration(milliseconds: 150),
                            );

                            if (!context.mounted) {
                              return;
                            }

                            final categoryName =
                                await _showAddCategoryBottomSheet(context);

                            if (categoryName == null) {
                              return;
                            }

                            try {
                              await onAddCategory!(categoryName);

                              if (!context.mounted) {
                                return;
                              }

                              showAnimatedSnackDialog(
                                context,
                                message: 'category_added_successfully'.tr(),
                                type: AnimatedSnackBarType.success,
                              );
                            } catch (e) {
                              if (!context.mounted) {
                                return;
                              }

                              if (e.toString().contains(
                                'category_already_exists',
                              )) {
                                showAnimatedSnackDialog(
                                  context,
                                  message: 'category_already_exists'.tr(),
                                  type: AnimatedSnackBarType.error,
                                );

                                return;
                              }

                              showAnimatedSnackDialog(
                                context,
                                message: 'something_went_wrong'.tr(),
                                type: AnimatedSnackBarType.error,
                              );
                            }
                          },
                        )
                      : null,
                ),
              ),

              itemBuilder: (context, item, isDisabled, isSelected) {
                return ListTile(title: Text(item));
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _showAddCategoryBottomSheet(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return const _AddCategorySheet();
      },
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  late final TextEditingController _controller;

  bool _isAddingCategory = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _submit() {
    final categoryName = _controller.text.trim();

    if (categoryName.isEmpty) {
      showAnimatedSnackDialog(
        context,
        message: 'enter_category_name'.tr(),
        type: AnimatedSnackBarType.error,
      );

      return;
    }

    if (_isAddingCategory) {
      return;
    }

    setState(() {
      _isAddingCategory = true;
    });

    Navigator.of(context).pop(categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Container(
        padding: EdgeInsets.all(20.w),

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,

          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,

                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),

                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                'add_new_category'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8.h),

              Text(
                'enter_category_name_description'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              SizedBox(height: 20.h),

              TextField(
                controller: _controller,

                autofocus: true,

                enabled: !_isAddingCategory,

                textInputAction: TextInputAction.done,

                decoration: InputDecoration(
                  hintText: 'category_name'.tr(),

                  prefixIcon: const Icon(Icons.category_outlined),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),

                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),

                    borderSide: const BorderSide(
                      color: Color(0xffC67A3D),
                      width: 1.5,
                    ),
                  ),
                ),

                onSubmitted: (_) {
                  _submit();
                },
              ),

              SizedBox(height: 20.h),

              SizedBox(
                width: double.infinity,
                height: 55.h,

                child: ElevatedButton.icon(
                  onPressed: _isAddingCategory ? null : _submit,

                  icon: const Icon(Icons.add),

                  label: Text('add_category'.tr()),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
