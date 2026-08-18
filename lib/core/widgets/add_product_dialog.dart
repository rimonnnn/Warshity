import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/dialog_action_buttons.dart';
import 'package:warshity/core/widgets/product_image_picker.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_state.dart';
import 'package:warshity/features/products/presentation/widgets/product_controllers.dart';
import 'package:warshity/features/products/presentation/widgets/product_form_fields.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key, this.imagecontainerheight});
  final double? imagecontainerheight;
  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final controllers = ProductControllers();
  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  String? selectedCategory;
  String selectedUnit = 'Piece'.tr();
  bool isSaving = false;
  final units = ['Piece'.tr(), 'Meter'.tr(), 'Kg'.tr()];
  @override
  void dispose() {
    controllers.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
    } catch (e) {
      if (mounted) {
        _message(e.toString());
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      _message('Please select a category'.tr());
      return;
    }
    if (isSaving) return;
    setState(() => isSaving = true);
    try {
      final product = ProductModel(
        id: '',
        name: controllers.name.text.trim(),
        barcode: controllers.barcode.text.trim(),
        category: selectedCategory!,
        price: double.tryParse(controllers.price.text.trim()) ?? 0,
        quantity: int.tryParse(controllers.quantity.text.trim()) ?? 0,
        unit: selectedUnit,
        imageUrl: '',
      );
      await context.read<AddProductCubit>().addProduct(
        product: product,
        imageBytes: selectedImageBytes,
        imageName: selectedImage?.name,
      );
      if (!mounted) return;
      final state = context.read<AddProductCubit>().state;
      if (state is AddProductSuccess) {
        _message('Product added successfully'.tr());

        Navigator.pop(context);
        return;
      }
      if (state is AddProductError) {
        _message(state.message);
      }
      setState(() => isSaving = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      _message(e.toString());
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 24.h),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),

      backgroundColor: context.colors.surface,

      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500.w,
          maxHeight: MediaQuery.of(context).size.height * .90,
        ),

        child: Padding(
          padding: EdgeInsets.all(24.w),

          child: Form(
            key: _formKey,

            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Add New Product'.tr(),
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  HeightSpace(20.h),

                  ProductImagePicker(
                    imageBytes: selectedImageBytes,
                    height: widget.imagecontainerheight,
                    onPick: _pickImage,
                    enabled: !isSaving,
                  ),

                  HeightSpace(20.h),

                  ProductFormFields(
                    controllers: controllers,
                    selectedCategory: selectedCategory,
                    selectedUnit: selectedUnit,
                    units: units,
                    enabled: !isSaving,
                    onCategoryChanged: (value) {
                      setState(() => selectedCategory = value);
                    },
                    onUnitChanged: (value) {
                      setState(() => selectedUnit = value);
                    },
                  ),

                  HeightSpace(30.h),

                  DialogActionButtons(
                    isLoading: isSaving,
                    onCancel: isSaving ? null : () => Navigator.pop(context),
                    onSave: _save,
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