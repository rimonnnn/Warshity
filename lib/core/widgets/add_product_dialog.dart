import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController barcodeController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? selectedImage;

  String? selectedCategory;

  String selectedUnit = 'Piece';

  bool isSaving = false;

  final List<String> units = [
    'Piece',
    'Meter',
    'Kg',
  ];

  @override
  void dispose() {
    nameController.dispose();
    barcodeController.dispose();
    priceController.dispose();
    quantityController.dispose();

    super.dispose();
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  Future<void> _showAddCategoryDialog() async {
    final TextEditingController controller =
        TextEditingController();

    // نفس CategoriesCubit الموجود في صفحة Products
    final categoriesCubit =
        context.read<CategoriesCubit>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isAdding = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add New Category',
              ),

              content: TextField(
                controller: controller,
                autofocus: true,
                enabled: !isAdding,
                textCapitalization:
                    TextCapitalization.words,

                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Example: Electrical',
                ),
              ),

              actions: [
                // ==================================================
                // CANCEL
                // ==================================================

                TextButton(
                  onPressed: isAdding
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                // ==================================================
                // ADD
                // ==================================================

                ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () async {
                          final name =
                              controller.text.trim();

                          // ---------------- Validation ----------------

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Category name is required',
                                ),
                              ),
                            );

                            return;
                          }

                          // ---------------- Loading ----------------

                          setDialogState(() {
                            isAdding = true;
                          });

                          try {
                            await categoriesCubit
                                .addCategory(name);

                            if (!context.mounted) {
                              return;
                            }

                            // ==========================================
                            // Check Cubit State
                            // ==========================================

                            final currentState =
                                categoriesCubit.state;

                            if (currentState
                                is AddCategoryError) {
                              setDialogState(() {
                                isAdding = false;
                              });

                              ScaffoldMessenger.of(
                                dialogContext,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    currentState.message,
                                  ),
                                ),
                              );

                              return;
                            }

                            // ==========================================
                            // SUCCESS
                            // ==========================================

                            Navigator.pop(
                              dialogContext,
                            );
                          } catch (e) {
                            setDialogState(() {
                              isAdding = false;
                            });

                            if (!dialogContext.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                        },

                  child: isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
      });
    } catch (e) {
      debugPrint(
        'Image Picker Error: $e',
      );
    }
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null ||
        selectedCategory!.isEmpty) {
      return;
    }

    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final String name =
          nameController.text.trim();

      final String barcode =
          barcodeController.text.trim();

      final double price =
          double.tryParse(
                priceController.text.trim(),
              ) ??
              0;

      final double quantity =
          double.tryParse(
                quantityController.text.trim(),
              ) ??
              0;

      debugPrint(
        'Product Name: $name',
      );

      debugPrint(
        'Barcode: $barcode',
      );

      debugPrint(
        'Price: $price',
      );

      debugPrint(
        'Quantity: $quantity',
      );

      debugPrint(
        'Category: $selectedCategory',
      );

      debugPrint(
        'Unit: $selectedUnit',
      );

      debugPrint(
        'Image: ${selectedImage?.path}',
      );

      // ==========================================================
      // AddProductCubit هنربطه بعدين
      // ==========================================================

      await Future.delayed(
        const Duration(
          seconds: 1,
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(
        'Save Product Error: $e',
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon),

      contentPadding:
          EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.sm,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.sm,
        ),
        borderSide: BorderSide(
          color: context.colors.outline,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.sm,
        ),
        borderSide: BorderSide(
          color: context.colors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _label(String text) {
    return Text(
      text,
      style:
          context.text.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double dialogWidth =
        MediaQuery.of(context).size.width *
            0.90;

    return Dialog(
      insetPadding:
          EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 24.h,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
      ),

      backgroundColor:
          context.colors.surface,

      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500.w,
          maxHeight:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.90,
        ),

        child: SizedBox(
          width: dialogWidth,

          child: Form(
            key: _formKey,

            child:
                SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding:
                  EdgeInsets.all(24.w),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    'Add New Product',
                    style: context
                        .text
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  HeightSpace(20.h),

                  // ==================================================
                  // PRODUCT IMAGE
                  // ==================================================

                  _label(
                    'Product Image',
                  ),

                  HeightSpace(10.h),

                  GestureDetector(
                    onTap: isSaving
                        ? null
                        : _pickImage,

                    child: Container(
                      width:
                          double.infinity,

                      height: 150.h,

                      decoration:
                          BoxDecoration(
                        border:
                            Border.all(
                          color: context
                              .colors
                              .outline,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          AppRadius.md,
                        ),
                      ),

                      clipBehavior:
                          Clip.antiAlias,

                      child:
                          selectedImage !=
                                  null
                              ? Image.file(
                                  selectedImage!,
                                  width:
                                      double.infinity,
                                  height:
                                      double.infinity,
                                  fit: BoxFit
                                      .cover,
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Icon(
                                      Icons
                                          .add_photo_alternate_outlined,
                                      size:
                                          48.sp,
                                      color: context
                                          .colors
                                          .primary,
                                    ),

                                    HeightSpace(
                                      8.h,
                                    ),

                                    Text(
                                      'Upload Product Image',
                                      style: context
                                          .text
                                          .titleMedium
                                          ?.copyWith(
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),

                                    HeightSpace(
                                      4.h,
                                    ),

                                    Text(
                                      'PNG, JPG',
                                      style: context
                                          .text
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                    ),
                  ),

                  HeightSpace(18.h),

                  // ==================================================
                  // PRODUCT NAME
                  // ==================================================

                  _label(
                    'Product Name',
                  ),

                  HeightSpace(8.h),

                  TextFormField(
                    controller:
                        nameController,

                    maxLines: 2,
                    minLines: 1,

                    keyboardType:
                        TextInputType.name,

                    textInputAction:
                        TextInputAction.next,

                    decoration:
                        _inputDecoration(
                      icon: Icons
                          .inventory_2_outlined,
                      hint:
                          'Example: Beech Wood Chair',
                    ),

                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Product name is required';
                      }

                      return null;
                    },
                  ),

                  HeightSpace(16.h),

                  // ==================================================
                  // CATEGORY
                  // ==================================================

                  _label(
                    'Category',
                  ),

                  HeightSpace(8.h),

                  BlocBuilder<
                      CategoriesCubit,
                      CategoriesState>(
                    builder:
                        (context, state) {
                      // ============================================
                      // Loading
                      // ============================================

                      if (state
                          is CategoriesLoading) {
                        return Container(
                          height: 55.h,

                          alignment:
                              Alignment.center,

                          decoration:
                              BoxDecoration(
                            border:
                                Border.all(
                              color: context
                                  .colors
                                  .outline,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.sm,
                            ),
                          ),

                          child:
                              const SizedBox(
                            width: 22,
                            height: 22,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      // ============================================
                      // Categories
                      // ============================================

                      List categories = [];

                      if (state
                          is CategoriesLoaded) {
                        categories =
                            state.categories;
                      } else if (state
                          is AddCategoryLoading) {
                        categories =
                            state.categories;
                      } else if (state
                          is AddCategoryError) {
                        categories =
                            state.categories;
                      }

                      return DropdownButtonFormField<
                          String>(
                        value:
                            selectedCategory,

                        isExpanded: true,

                        decoration:
                            InputDecoration(
                          prefixIcon:
                              const Icon(
                            Icons
                                .category_outlined,
                          ),

                          contentPadding:
                              EdgeInsets.symmetric(
                            horizontal:
                                14.w,
                            vertical:
                                14.h,
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.sm,
                            ),
                          ),

                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.sm,
                            ),

                            borderSide:
                                BorderSide(
                              color: context
                                  .colors
                                  .outline,
                            ),
                          ),

                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.sm,
                            ),

                            borderSide:
                                BorderSide(
                              color: context
                                  .colors
                                  .primary,

                              width: 1.5,
                            ),
                          ),
                        ),

                        hint: const Text(
                          'Select Category',
                        ),

                        items: [
                          // ========================================
                          // Firebase Categories
                          // ========================================

                          ...categories.map(
                            (category) {
                              return DropdownMenuItem<
                                  String>(
                                value:
                                    category.name,

                                child: Text(
                                  category.name,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                              );
                            },
                          ),

                          // ========================================
                          // Add New Category
                          // ========================================

                          const DropdownMenuItem<
                              String>(
                            value:
                                '__add_category__',

                            child: Row(
                              children: [
                                Icon(
                                  Icons.add,
                                ),

                                SizedBox(
                                  width: 8,
                                ),

                                Text(
                                  'Add New Category',
                                ),
                              ],
                            ),
                          ),
                        ],

                        onChanged:
                            isSaving
                                ? null
                                : (value) async {
                                    if (value ==
                                        '__add_category__') {
                                      await _showAddCategoryDialog();

                                      return;
                                    }

                                    setState(
                                      () {
                                        selectedCategory =
                                            value;
                                      },
                                    );
                                  },

                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {
                            return 'Please select a category';
                          }

                          return null;
                        },
                      );
                    },
                  ),

                  HeightSpace(16.h),

                  // ==================================================
                  // CODE + PRICE
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      // Product Code
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            _label(
                              'Product Code',
                            ),

                            HeightSpace(
                              8.h,
                            ),

                            TextFormField(
                              controller:
                                  barcodeController,

                              maxLines: 1,
                              minLines: 1,

                              keyboardType:
                                  TextInputType
                                      .text,

                              textInputAction:
                                  TextInputAction
                                      .next,

                              decoration:
                                  _inputDecoration(
                                icon: Icons
                                    .qr_code_2,
                                hint:
                                    'SKU-0000',
                              ),

                              validator:
                                  (value) {
                                if (value ==
                                        null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'Required';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width: 12.w,
                      ),

                      // Selling Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            _label(
                              'Selling Price',
                            ),

                            HeightSpace(
                              8.h,
                            ),

                            TextFormField(
                              controller:
                                  priceController,

                              maxLines: 1,
                              minLines: 1,

                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),

                              textInputAction:
                                  TextInputAction
                                      .next,

                              decoration:
                                  _inputDecoration(
                                icon: Icons
                                    .payments_outlined,
                                hint:
                                    '0.00',
                              ),

                              validator:
                                  AppValidators
                                      .amount,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  HeightSpace(16.h),

                  // ==================================================
                  // CURRENT QUANTITY
                  // ==================================================

                  _label(
                    'Current Quantity',
                  ),

                  HeightSpace(8.h),

                  TextFormField(
                    controller:
                        quantityController,

                    maxLines: 1,
                    minLines: 1,

                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),

                    textInputAction:
                        TextInputAction.done,

                    decoration:
                        _inputDecoration(
                      icon: Icons
                          .inventory_outlined,
                      hint: '0',
                    ),

                    validator:
                        AppValidators
                            .amount,
                  ),

                  HeightSpace(16.h),

                  // ==================================================
                  // UNIT
                  // ==================================================

                  _label(
                    'Unit',
                  ),

                  HeightSpace(8.h),

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,

                    children:
                        units.map(
                      (unit) {
                        final bool
                            isSelected =
                            selectedUnit ==
                                unit;

                        return ChoiceChip(
                          label:
                              Text(unit),

                          selected:
                              isSelected,

                          onSelected:
                              isSaving
                                  ? null
                                  : (_) {
                                      setState(
                                        () {
                                          selectedUnit =
                                              unit;
                                        },
                                      );
                                    },

                          selectedColor:
                              context
                                  .colors
                                  .primaryContainer,

                          labelStyle:
                              context
                                  .text
                                  .bodyMedium
                                  ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        );
                      },
                    ).toList(),
                  ),

                  HeightSpace(28.h),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  Row(
                    children: [
                      // =================================================
                      // CANCEL
                      // =================================================

                      Expanded(
                        child: SizedBox(
                          height: 56.h,

                          child:
                              TextButton(
                            onPressed:
                                isSaving
                                    ? null
                                    : () => context
                                        .pop(),

                            child: Text(
                              'Cancel',

                              style: context
                                  .text
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 12.w,
                      ),

                      // =================================================
                      // SAVE
                      // =================================================

                      Expanded(
                        child: SizedBox(
                          height: 56.h,

                          child:
                              ElevatedButton(
                            onPressed:
                                isSaving
                                    ? null
                                    : _onSave,

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  context
                                      .colors
                                      .primary,

                              disabledBackgroundColor:
                                  context
                                      .colors
                                      .primary
                                      .withValues(
                                alpha:
                                    0.45,
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  AppRadius
                                      .md,
                                ),
                              ),

                              elevation: 0,
                            ),

                            child:
                                AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds:
                                    200,
                              ),

                              child: isSaving
                                  ? Row(
                                      key: const ValueKey(
                                        'saving',
                                      ),

                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,

                                      mainAxisSize:
                                          MainAxisSize
                                              .min,

                                      children: [
                                        SizedBox(
                                          width:
                                              20.w,
                                          height:
                                              20.w,

                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2.2,

                                            color: context
                                                .colors
                                                .primaryContainer,
                                          ),
                                        ),

                                        SizedBox(
                                          width:
                                              8.w,
                                        ),

                                        Flexible(
                                          child:
                                              Text(
                                            'Saving...',
                                            maxLines:
                                                1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,

                                            style: context
                                                .text
                                                .titleMedium
                                                ?.copyWith(
                                              color: context
                                                  .colors
                                                  .primaryContainer,

                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      key: const ValueKey(
                                        'save',
                                      ),

                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,

                                      mainAxisSize:
                                          MainAxisSize
                                              .min,

                                      children: [
                                        Icon(
                                          Icons
                                              .save,

                                          size:
                                              20.sp,

                                          color: context
                                              .colors
                                              .primaryContainer,
                                        ),

                                        SizedBox(
                                          width:
                                              8.w,
                                        ),

                                        Text(
                                          'Save',
                                          maxLines:
                                              1,

                                          style: context
                                              .text
                                              .titleMedium
                                              ?.copyWith(
                                            color: context
                                                .colors
                                                .primaryContainer,

                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  HeightSpace(8.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}