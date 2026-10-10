import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/custom_dropdown_products.dart';

class ProductsData {
  const ProductsData({required this.name, this.price, this.category});

  final String name;

  final double? price;
  final String? category;
}

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  static const List<String> _categories = [
    'wood',
    'glue',
    'accessories',
    'rivets',
    'other',
  ];

  String? _selectedCategory;

  @override
  void dispose() {
    nameController.dispose();

    priceController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('please_select_category'.tr())));
      return;
    }

    final result = ProductsData(
      name: nameController.text.trim(),

      price: double.parse(priceController.text.trim()),
      category: _selectedCategory!,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      // surfaceContainer بدل surface، عشان الـ dialog يبان فوق الخلفية
      backgroundColor: scheme.surfaceContainer,
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Form(
          key: _formKey,
          // الأخطاء بتظهر أول ما المستخدم يسيب الحقل، مش بس بعد الضغط على حفظ
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header: أيقونة + عنوان + زر إغلاق، زي dialog إضافة العميل
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
                        'add_new_product'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'cancel'.tr(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                HeightSpace(20),
                CustomTextField(
                  label: 'product_name'.tr(),
                  hint: 'product_name_hint'.tr(),
                  prefixIconData: Icons.shopping_bag_outlined,
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  validator: AppValidators.clientName,
                ),

                HeightSpace(16),
                CustomTextField(
                  label: 'product_price'.tr(),
                  hint: 'price_hint'.tr(),
                  prefixIconData: Icons.attach_money,
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => AppValidators.price(value),
                ),
                HeightSpace(16),
                CustomDropdownProducts(
                  label: 'category'.tr(),
                  hint: 'select_category'.tr(),
                  items: _categories.map((c) => c.tr()).toList(),
                  selectedItem: _selectedCategory?.tr(),
                  onSelected: (value) {
                    final key = _categories.firstWhere(
                      (c) => c.tr() == value,
                      orElse: () => value ?? '',
                    );
                    setState(() => _selectedCategory = key);
                  },
                ),
                HeightSpace(28),
                Row(
                  children: [
                    Expanded(
                      // outlined بدل TextButton: زر إلغاء واضح إنه زر
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 52.h),
                          foregroundColor: scheme.onSurface,
                          side: BorderSide(color: scheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: Text(
                          'cancel'.tr(),
                          style: context.text.bodyLarge?.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: PrimaryButtonWidget(
                        height: 52.h,
                        // 20 كانت كبيرة جنب زر الإلغاء
                        fontSize: 16.sp,
                        buttonText: 'save'.tr(),
                        buttonColor: scheme.primary,
                        textColor: scheme.onPrimary,
                        borderRadius: AppRadius.sm,
                        onPress: _onSave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
