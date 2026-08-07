import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

/// نتيجة الديالوج بعد ما المستخدم يحفظ البيانات.
/// موديل بسيط بدل ما نرجع Map عشان يبقى فيه type safety.
class ClientAndProductData {
  const ClientAndProductData({required this.name, this.phone, this.address});

  final String name;
  final String? phone;
  final String? address;
}

/// Dialog لإضافة بيانات العميل + تفاصيل الفاتورة (السعر والتصنيف) مع بعض.
/// بيرجع null لو المستخدم عمل إلغاء، أو ClientAndProductData لو حفظ بنجاح.
class AddClientDialog extends StatefulWidget {
  const AddClientDialog({super.key});

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();

    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final result = ClientAndProductData(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
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
                  'add_client'.tr(),
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                HeightSpace(20),
                CustomTextField(
                  label: 'client_name'.tr(),
                  hint: 'client_name_hint'.tr(),
                  prefixIconData: Icons.person,
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  validator: AppValidators.clientName,
                ),
                HeightSpace(16),
                CustomTextField(
                  label: 'phone'.tr(),
                  hint: 'phone_hint'.tr(),
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.phone,
                  prefixIconData: Icons.phone,
                ),
                HeightSpace(16),
                CustomTextField(
                  label: 'address'.tr(),
                  hint: 'address_hint'.tr(),
                  controller: addressController,
                  keyboardType: TextInputType.streetAddress,
                  prefixIconData: Icons.location_on,

                  validator: (value) => AppValidators.address(value),
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
