import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/products/data/models/product_model.dart';

import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_state.dart';

import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({
    super.key,
    this.imagecontainerheight,
  });

  final double? imagecontainerheight;

  @override
  State<AddProductDialog> createState() =>
      _AddProductDialogState();
}

class _AddProductDialogState
    extends State<AddProductDialog> {
  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController barcodeController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController categoryController =
      TextEditingController();

  // ============================================================
  // IMAGE
  // ============================================================

  final ImagePicker _imagePicker =
      ImagePicker();

  XFile? selectedImage;

  Uint8List? selectedImageBytes;

  // ============================================================
  // CATEGORY
  // ============================================================

  String? selectedCategory;

  bool showAddCategory = false;

  bool isAddingCategory = false;

  // ============================================================
  // UNIT
  // ============================================================

  String selectedUnit = 'Piece'.tr();

  final List<String> units = [
    'Piece'.tr(),
    'Meter'.tr(),
    'Kg'.tr(),
  ];

  // ============================================================
  // SAVE
  // ============================================================

  bool isSaving = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    barcodeController.dispose();
    priceController.dispose();
    quantityController.dispose();
    categoryController.dispose();

    super.dispose();
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

      if (image == null) {
        return;
      }

      final Uint8List bytes =
          await image.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
    } catch (e) {
      debugPrint(
        'Image Picker Error: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select image'.tr(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  Future<void> _addCategory() async {
    final String name =
        categoryController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Category name is required'.tr(),
          ),
        ),
      );

      return;
    }

    if (isAddingCategory) {
      return;
    }

    setState(() {
      isAddingCategory = true;
    });

    try {
      final CategoriesCubit categoriesCubit =
          context.read<CategoriesCubit>();

      await categoriesCubit.addCategory(name);

      if (!mounted) {
        return;
      }

      final CategoriesState currentState =
          categoriesCubit.state;

      if (currentState
          is AddCategoryError) {
        setState(() {
          isAddingCategory = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentState.message,
            ),
          ),
        );

        return;
      }

      setState(() {
        selectedCategory = name;
        showAddCategory = false;
        isAddingCategory = false;
        categoryController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Category added successfully'.tr(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isAddingCategory = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a category'.tr(),
          ),
        ),
      );

      return;
    }

    if (isSaving) {
      return;
    }

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

      final int quantity =
          int.tryParse(
                quantityController.text.trim(),
              ) ??
              0;

      final ProductModel product =
          ProductModel(
        id: '',
        name: name,
        barcode: barcode,
        category: selectedCategory!,
        price: price,
        quantity: quantity,
        unit: selectedUnit,
        imageUrl: '',
      );

      await context
          .read<AddProductCubit>()
          .addProduct(
            product: product,
            imageBytes: selectedImageBytes,
            imageName: selectedImage?.name,
          );

      if (!mounted) {
        return;
      }

      final AddProductState state =
          context
              .read<AddProductCubit>()
              .state;

      if (state is AddProductSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product added successfully'.tr(),
            ),
          ),
        );

        Navigator.of(context).pop();

        return;
      }

      if (state is AddProductError) {
        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.message,
            ),
          ),
        );

        return;
      }

      setState(() {
        isSaving = false;
      });
    } catch (e) {
      debugPrint(
        'Save Product Error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
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
        constraints:
            BoxConstraints(
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
                    'Add New Product'.tr(),
                    style: context.text
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  HeightSpace(20.h),

                  // ==================================================
                  // IMAGE
                  // ==================================================

                  _label(
                    'Product Image'.tr(),
                  ),

                  HeightSpace(10.h),

                  GestureDetector(
                    onTap: isSaving
                        ? null
                        : _pickImage,

                    child: Container(
                      width:
                          double.infinity,

                      height:
                          widget.imagecontainerheight ??
                              150.h,

                      decoration:
                          BoxDecoration(
                        border: Border.all(
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
                          selectedImageBytes !=
                                  null
                              ? Image.memory(
                                  selectedImageBytes!,
                                  fit: BoxFit.cover,
                                  width:
                                      double.infinity,
                                  height:
                                      double.infinity,
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Icon(
                                      Icons
                                          .add_photo_alternate_outlined,
                                      size: 48.sp,
                                      color: context
                                          .colors
                                          .primary,
                                    ),

                                    HeightSpace(
                                      8.h,
                                    ),

                                    Text(
                                      'Upload Product Image'
                                          .tr(),
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
                                      'PNG, JPG'
                                          .tr(),
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
                    'Product Name'.tr(),
                  ),

                  HeightSpace(8.h),

                  TextFormField(
                    controller:
                        nameController,

                    keyboardType:
                        TextInputType.name,

                    textInputAction:
                        TextInputAction.next,

                    decoration:
                        _inputDecoration(
                      icon: Icons
                          .inventory_2_outlined,
                      hint:
                          'Example: Beech Wood Chair'
                              .tr(),
                    ),

                    validator:
                        (value) {
                      if (value ==
                              null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Product name is required'
                            .tr();
                      }

                      return null;
                    },
                  ),

                  HeightSpace(16.h),

                  // ==================================================
                  // CATEGORY
                  // ==================================================

                  _label(
                    'Category'.tr(),
                  ),

                  HeightSpace(8.h),

                  BlocBuilder<
                      CategoriesCubit,
                      CategoriesState>(
                    builder:
                        (context, state) {
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

                      final bool loading =
                          state
                              is CategoriesLoading;

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          DropdownButtonFormField<
                              String>(
                            value:
                                selectedCategory,

                            isExpanded:
                                true,

                            decoration:
                                InputDecoration(
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .category_outlined,
                              ),

                              hintText:
                                  'Select Category'
                                      .tr(),

                              contentPadding:
                                  EdgeInsets
                                      .symmetric(
                                horizontal:
                                    14.w,
                                vertical:
                                    14.h,
                              ),

                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  AppRadius
                                      .sm,
                                ),
                              ),

                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  AppRadius
                                      .sm,
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
                                    BorderRadius
                                        .circular(
                                  AppRadius
                                      .sm,
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

                            hint:
                                loading
                                    ? Row(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [
                                          SizedBox(
                                            width:
                                                18.w,
                                            height:
                                                18.w,
                                            child:
                                                const CircularProgressIndicator(
                                              strokeWidth:
                                                  2,
                                            ),
                                          ),

                                          SizedBox(
                                            width:
                                                10.w,
                                          ),

                                          Flexible(
                                            child:
                                                Text(
                                              'Loading categories...'
                                                  .tr(),
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,

                            items: [
                              ...categories.map<
                                  DropdownMenuItem<
                                      String>>(
                                (
                                  category,
                                ) {
                                  return DropdownMenuItem<
                                      String>(
                                    value:
                                        category
                                            .name,

                                    child:
                                        Row(
                                      children: [
                                        const Icon(
                                          Icons
                                              .category_outlined,
                                          size:
                                              20,
                                        ),

                                        SizedBox(
                                          width:
                                              10.w,
                                        ),

                                        Expanded(
                                          child:
                                              Text(
                                            category
                                                .name,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              DropdownMenuItem<
                                  String>(
                                value:
                                    '__add_category__',

                                child:
                                    Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .add_circle_outline,
                                    ),

                                    SizedBox(
                                      width:
                                          10.w,
                                    ),

                                    Flexible(
                                      child:
                                          Text(
                                        'Add New Category'
                                            .tr(),
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            onChanged:
                                isSaving ||
                                        isAddingCategory
                                    ? null
                                    : (value) {
                                        if (value ==
                                            null) {
                                          return;
                                        }

                                        if (value ==
                                            '__add_category__') {
                                          setState(
                                            () {
                                              showAddCategory =
                                                  true;

                                              categoryController
                                                  .clear();
                                            },
                                          );

                                          return;
                                        }

                                        setState(
                                          () {
                                            selectedCategory =
                                                value;

                                            showAddCategory =
                                                false;
                                          },
                                        );
                                      },

                            validator:
                                (value) {
                              if (selectedCategory ==
                                      null ||
                                  selectedCategory!
                                      .isEmpty) {
                                return 'Please select a category'
                                    .tr();
                              }

                              return null;
                            },
                          ),

                          // ==================================================
                          // ADD NEW CATEGORY
                          // ==================================================

                          if (showAddCategory) ...[
                            HeightSpace(10.h),

                            Container(
                              width:
                                  double.infinity,

                              padding:
                                  EdgeInsets.all(
                                12.w,
                              ),

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
                                  AppRadius
                                      .sm,
                                ),
                              ),

                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Text(
                                    'Add New Category'
                                        .tr(),

                                    style: context
                                        .text
                                        .titleMedium
                                        ?.copyWith(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  HeightSpace(
                                    8.h,
                                  ),

                                  TextField(
                                    controller:
                                        categoryController,

                                    enabled:
                                        !isAddingCategory,

                                    textCapitalization:
                                        TextCapitalization
                                            .words,

                                    decoration:
                                        InputDecoration(
                                      hintText:
                                          'Category name'
                                              .tr(),

                                      prefixIcon:
                                          const Icon(
                                        Icons
                                            .category_outlined,
                                      ),

                                      border:
                                          OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          AppRadius
                                              .sm,
                                        ),
                                      ),
                                    ),
                                  ),

                                  HeightSpace(
                                    10.h,
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child:
                                            OutlinedButton(
                                          onPressed:
                                              isAddingCategory
                                                  ? null
                                                  : () {
                                                      setState(
                                                        () {
                                                          showAddCategory =
                                                              false;

                                                          categoryController
                                                              .clear();
                                                        },
                                                      );
                                                    },

                                          child:
                                              Text(
                                            'Cancel'
                                                .tr(),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        width:
                                            8.w,
                                      ),

                                      Expanded(
                                        child:
                                            ElevatedButton(
                                          onPressed:
                                              isAddingCategory
                                                  ? null
                                                  : _addCategory,

                                          child:
                                              isAddingCategory
                                                  ? const SizedBox(
                                                      width:
                                                          20,
                                                      height:
                                                          20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth:
                                                            2,
                                                      ),
                                                    )
                                                  : Text(
                                                      'Add'
                                                          .tr(),
                                                    ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (state
                              is AddCategoryError)
                            Padding(
                              padding:
                                  EdgeInsets.only(
                                top: 8.h,
                              ),

                              child:
                                  Text(
                                state.message,

                                style:
                                    TextStyle(
                                  color: context
                                      .colors
                                      .error,
                                  fontSize:
                                      12.sp,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  HeightSpace(16.h),

                  // ==================================================
                  // PRODUCT CODE + SELLING PRICE
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =================================================
                      // PRODUCT CODE
                      // =================================================

                      Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            _label(
                              'Product Code'
                                  .tr(),
                            ),

                            HeightSpace(
                              8.h,
                            ),

                            TextFormField(
                              controller:
                                  barcodeController,

                              keyboardType:
                                  TextInputType
                                      .text,

                              textInputAction:
                                  TextInputAction
                                      .next,

                              decoration:
                                  _inputDecoration(
                                icon:
                                    Icons.qr_code_2,
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
                                  return 'Required'
                                      .tr();
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

                      // =================================================
                      // SELLING PRICE
                      // =================================================

                      Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            _label(
                              'Selling Price'
                                  .tr(),
                            ),

                            HeightSpace(
                              8.h,
                            ),

                            TextFormField(
                              controller:
                                  priceController,

                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal:
                                    true,
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
                  // QUANTITY
                  // ==================================================

                  _label(
                    'Current Quantity'
                        .tr(),
                  ),

                  HeightSpace(8.h),

                  TextFormField(
                    controller:
                        quantityController,

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
                    'Unit'.tr(),
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
                        );
                      },
                    ).toList(),
                  ),

                  HeightSpace(30.h),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  Row(
                    children: [
                      // =================================================
                      // CANCEL
                      // =================================================

                      Expanded(
                        child:
                            SizedBox(
                          height: 56.h,

                          child:
                              ElevatedButton(
                            onPressed:
                                isSaving ||
                                        isAddingCategory
                                    ? null
                                    : () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.red,

                              foregroundColor:
                                  Colors.white,

                              elevation:
                                  0,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  AppRadius
                                      .md,
                                ),
                              ),
                            ),

                            child:
                                Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              mainAxisSize:
                                  MainAxisSize
                                      .min,

                              children: [
                                const Icon(
                                  Icons
                                      .cancel_outlined,
                                ),

                                SizedBox(
                                  width:
                                      6.w,
                                ),

                                Flexible(
                                  child:
                                      Text(
                                    'Cancel'
                                        .tr(),

                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 8.w,
                      ),

                      // =================================================
                      // SAVE
                      // =================================================

                      Expanded(
                        child:
                            SizedBox(
                          height: 56.h,

                          child:
                              ElevatedButton(
                            onPressed:
                                isSaving ||
                                        isAddingCategory
                                    ? null
                                    : _onSave,

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  context
                                      .colors
                                      .primary,

                              foregroundColor:
                                  Colors.white,

                              elevation:
                                  0,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  AppRadius
                                      .md,
                                ),
                              ),

                              padding:
                                  EdgeInsets
                                      .symmetric(
                                horizontal:
                                    8.w,
                              ),
                            ),

                            child:
                                isSaving
                                    ? const SizedBox(
                                        width:
                                            22,
                                        height:
                                            22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,

                                        mainAxisSize:
                                            MainAxisSize
                                                .min,

                                        children: [
                                          const Icon(
                                            Icons
                                                .save,
                                            size:
                                                20,
                                          ),

                                          SizedBox(
                                            width:
                                                6.w,
                                          ),

                                          Flexible(
                                            child:
                                                Text(
                                              'save'
                                                  .tr(),

                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,

                                              maxLines:
                                                  1,

                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}