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

/// نتيجة الديالوج بعد ما المستخدم يحفظ البيانات.
/// موديل بسيط بدل ما نرجع Map عشان يبقى فيه type safety.
class ProductsData {
  const ProductsData({required this.name, this.price, this.category});

  final String name;

  final double? price;
  final String? category;
}

/// Dialog لإضافة بيانات العميل + تفاصيل الفاتورة (السعر والتصنيف) مع بعض.
/// بيرجع null لو المستخدم عمل إلغاء، أو ClientAndProductData لو حفظ بنجاح.
class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  // TODO: استبدل القايمة دي بالتصنيفات الفعلية بتاعتك (ممكن تيجي من enum أو من API)
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      backgroundColor: context.colors.surface,
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'add_new_product'.tr(),
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                    // بما إن العناصر المعروضة مترجمة، لازم نرجع نلاقي المفتاح
                    // الأصلي المطابق للقيمة المختارة قبل ما نخزنها
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
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'cancel'.tr(),
                          style: context.text.bodyLarge?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: PrimaryButtonWidget(
                        fontSize: 20,
                        buttonText: 'save'.tr(),
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
