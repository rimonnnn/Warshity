import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/add_product_form_fields.dart';
import 'package:warshity/core/widgets/add_unit_dialog.dart';
import 'package:warshity/core/widgets/dialog_action_buttons.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_state.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({
    super.key,
    this.imagecontainerheight,
    this.productnamefieldheight,
    this.productcodefieldheight,
    this.sellingpricefieldheight,
    this.currentquantityfieldheight,
    this.savebuttonheight,
    this.cancelbuttonheight,
  });

  final double? imagecontainerheight;
  final double? productnamefieldheight;
  final double? productcodefieldheight;
  final double? sellingpricefieldheight;
  final double? currentquantityfieldheight;
  final double? savebuttonheight;
  final double? cancelbuttonheight;

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final barcodeController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;
  Uint8List? selectedImageBytes;

  String? selectedCategory;
  String selectedUnit = 'Piece'.tr();

  bool isSaving = false;
  bool isGeneratingBarcode = false;
  bool isLoadingCustomUnits = false;
  bool isAddingUnit = false;

  List<String> units = ['Piece'.tr(), 'Meter'.tr(), 'Kg'.tr()];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _generateBarcode();
        _loadCustomUnits();
      }
    });
  }

  Future<void> _generateBarcode() async {
    if (!mounted || isGeneratingBarcode) return;

    setState(() {
      isGeneratingBarcode = true;
    });

    try {
      final cubit = context.read<AddProductCubit>();
      final barcode = await cubit.generateProductBarcode();

      if (!mounted) return;

      setState(() {
        barcodeController.text = barcode;
        isGeneratingBarcode = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isGeneratingBarcode = false;
      });

      _message('Failed to generate product code. Please try again.'.tr());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    barcodeController.dispose();
    priceController.dispose();
    quantityController.dispose();
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
    // ignore: empty_catches
    } catch (e) {}
  }

  List<String> _mergeUnits(Iterable<String> values) {
    final result = <String>[];
    final seen = <String>{};

    for (final value in values) {
      final unit = value.trim();
      if (unit.isEmpty) continue;

      final key = unit.toLowerCase();
      if (seen.add(key)) {
        result.add(unit);
      }
    }

    return result;
  }

  Future<void> _loadCustomUnits() async {
    if (isLoadingCustomUnits) return;

    setState(() => isLoadingCustomUnits = true);

    try {
      final customUnits = await context
          .read<AddProductCubit>()
          .getCustomUnits();

      if (!mounted) return;

      setState(() {
        units = _mergeUnits([
          'Piece'.tr(),
          'Meter'.tr(),
          'Kg'.tr(),
          ...customUnits,
        ]);
        isLoadingCustomUnits = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingCustomUnits = false);
      _showUnitMessage(
        'custom_units_load_failed',
        type: AnimatedSnackBarType.error,
      );
    }
  }

  Future<void> _showAddUnitDialog() async {
    if (isSaving || isAddingUnit || isLoadingCustomUnits) return;

    final name = await AddUnitDialog.show(context, existingUnits: units);

    if (name == null || !mounted) return;

    setState(() => isAddingUnit = true);

    try {
      final cubit = context.read<AddProductCubit>();
      await cubit.addCustomUnit(name);

      if (!mounted) return;

      setState(() {
        units = _mergeUnits([...units, name]);
        isAddingUnit = false;
      });

      _showUnitMessage(
        'custom_unit_added_successfully',
        type: AnimatedSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isAddingUnit = false);
      
      _showUnitMessage(
        'custom_unit_save_failed',
        type: AnimatedSnackBarType.error,
      );
    }
  }

  Future<void> _save() async {
    if (isGeneratingBarcode) {
      _message('Please wait while the product code is generated'.tr());
      return;
    }

    if (barcodeController.text.trim().isEmpty) {
      await _generateBarcode();

      if (barcodeController.text.trim().isEmpty) {
        return;
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      _message('Please select a category'.tr());
      return;
    }

    if (isSaving || isAddingUnit || isLoadingCustomUnits) return;

    setState(() {
      isSaving = true;
    });

    try {
      final product = ProductModel(
        id: '',
        name: nameController.text.trim(),
        barcode: barcodeController.text.trim(),
        category: selectedCategory!,
        price: double.tryParse(priceController.text.trim()) ?? 0,
        quantity: int.tryParse(quantityController.text.trim()) ?? 0,
        unit: selectedUnit,
        imageUrl: '',
      );

      final cubit = context.read<AddProductCubit>();

      await cubit.addProduct(
        product: product,
        imageBytes: selectedImageBytes,
        imageName: selectedImage?.name,
      );

      if (!mounted) return;

      final state = cubit.state;

      if (state is AddProductSuccess) {
        _message('Product added successfully'.tr());

        Navigator.pop(context);
        return;
      }

      if (state is AddProductError) {
        _message(state.message);
      }

      setState(() {
        isSaving = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      _message(e.toString());
    }
  }

  void _showUnitMessage(
    String translationKey, {
    required AnimatedSnackBarType type,
  }) {
    if (!mounted) return;

    showAnimatedSnackDialog(context, message: translationKey.tr(), type: type);
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final bool isWeb = kIsWeb;
        final bool compact = screenWidth < 700;

        final double dialogWidth = isWeb
            ? (screenWidth * 0.70).clamp(620.0, 820.0)
            : (screenWidth - 32).clamp(280.0, 520.0);

        final double dialogMaxHeight = screenHeight * 0.90;
        final double imageHeight = isWeb ? 155.0 : 135.0;
        final double horizontalPadding = isWeb ? 28.0 : 20.0;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 24,
            vertical: 20,
          ),

          backgroundColor: scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          child: SizedBox(
            width: dialogWidth,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: dialogMaxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Form(
                  key: _formKey,

                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 22,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add New Product'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isWeb ? 22 : 20,
                                    ),
                              ),
                            ),
                            IconButton(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              visualDensity: VisualDensity.compact,
                              onPressed:
                                  (isSaving ||
                                      isAddingUnit ||
                                      isLoadingCustomUnits)
                                  ? null
                                  : () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isWeb ? 20 : 16),

                        AddProductFormFields(
                          isWeb: isWeb,
                          isSaving: isSaving,
                          isUnitActionInProgress:
                              isAddingUnit || isLoadingCustomUnits,
                          nameController: nameController,
                          barcodeController: barcodeController,
                          priceController: priceController,
                          quantityController: quantityController,
                          selectedImageBytes: selectedImageBytes,
                          selectedCategory: selectedCategory,
                          selectedUnit: selectedUnit,
                          units: units,
                          imageHeight:
                              widget.imagecontainerheight ?? imageHeight,
                          productNameFieldHeight: widget.productnamefieldheight,
                          productCodeFieldHeight: widget.productcodefieldheight,
                          sellingPriceFieldHeight:
                              widget.sellingpricefieldheight,
                          currentQuantityFieldHeight:
                              widget.currentquantityfieldheight,
                          onPickImage: _pickImage,
                          onCategoryChanged: (value) {
                            setState(() => selectedCategory = value);
                          },
                          onUnitChanged: (unit) {
                            setState(() => selectedUnit = unit);
                          },
                          onAddUnit: _showAddUnitDialog,
                        ),

                        SizedBox(height: isWeb ? 24 : 22),

                        DialogActionButtons(
                          cancelbuttonheight: widget.cancelbuttonheight,
                          savebuttonheight: widget.savebuttonheight,
                          fontSize: isWeb ? 20 : 16.sp,
                          isLoading: isSaving,
                          fontSize1: isWeb ? 20 : 16.sp,
                          onCancel:
                              (isSaving || isAddingUnit || isLoadingCustomUnits)
                              ? null
                              : () => Navigator.pop(context),
                          onSave:
                              (isSaving ||
                                  isGeneratingBarcode ||
                                  isAddingUnit ||
                                  isLoadingCustomUnits)
                              ? null
                              : _save,
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
