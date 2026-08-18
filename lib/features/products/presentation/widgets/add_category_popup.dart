import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';

import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';

class AddCategoryPopup {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    if (_entry != null) return;

    final cubit = context.read<CategoriesCubit>();

    final controller = TextEditingController();
    final focusNode = FocusNode();

    bool loading = false;

    late OverlayEntry entry;

    void close() {
      focusNode.unfocus();
      controller.dispose();
      focusNode.dispose();

      if (entry.mounted) {
        entry.remove();
      }

      _entry = null;
    }

    Future<void> addCategory(
      BuildContext popupContext,
      StateSetter setState,
    ) async {
      final name = controller.text.trim();

      if (name.isEmpty || loading) {
        return;
      }

      setState(() {
        loading = true;
      });

      try {
        focusNode.unfocus();

        await cubit.addCategory(name);

        if (cubit.state is AddCategoryError) {
          if (entry.mounted) {
            setState(() {
              loading = false;
            });
          }

          return;
        }

        close();
      } catch (_) {
        if (entry.mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    }

    entry = OverlayEntry(
      builder: (overlayContext) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              
              
              
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: close,
                  child: Container(color: Colors.black.withValues(alpha: 0.25)),
                ),
              ),

              
              
              
              Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 380.w,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 25,
                              spreadRadius: 2,
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            
                            
                            Text(
                              'Add New Category'.tr(),
                              style: context.text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 20.h),

                            
                            
                            
                            CustomTextField(
                              controller: controller,
                              hint: 'Category name'.tr(),
                              width: double.infinity,
                              prefixIconData: Icons.category_outlined,
                              onTap: () {},
                            ),

                            SizedBox(height: 24.h),

                            
                            
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: loading ? null : close,
                                  child: Text('Cancel'.tr()),
                                ),

                                SizedBox(width: 12.w),

                                PrimaryButtonWidget(
                                  width: 100.w,
                                  height: 45.h,
                                  buttonText: 'Add'.tr(),
                                  isLoading: loading,
                                  onPress: () => addCategory(context, setState),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    _entry = entry;

    Overlay.of(context).insert(entry);
  }
}
