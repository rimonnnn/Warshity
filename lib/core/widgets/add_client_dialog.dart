import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/customer_balance_type.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/Cleints/presentation/cubit/add_client_cubit.dart';

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
  final TextEditingController balanceController = TextEditingController();

  bool hasDebt = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final balance = num.tryParse(balanceController.text.trim()) ?? 0;

    final client = CustomerModel(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      balance: balance,

      address: addressController.text.trim(),
      hasDebt: hasDebt,
    );

    context.read<AddClientCubit>().addClient(client);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddClientCubit, AddClientState>(
      listener: (context, state) {
        if (state is AddClientSuccess) {
          Navigator.of(context).pop();

          showAnimatedSnackDialog(
            context,
            message: "client_added_successfully".tr(),
            type: AnimatedSnackBarType.success,
          );
        }

        if (state is AddClientError) {
          showAnimatedSnackDialog(
            context,
            message: "something_error".tr(),
            type: AnimatedSnackBarType.error,
          );
        }
      },

      builder: (context, state) {
        final isLoading = state is AddClientLoading;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),

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
              padding: EdgeInsets.all(16.sp),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                        validator: AppValidators.address,
                      ),

                      HeightSpace(16),

                      CustomerBalanceType(
                        value: hasDebt,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  hasDebt = value;
                                });
                              },
                      ),

                      HeightSpace(16),

                      hasDebt == true
                          ? CustomTextField(
                              label: 'debt_amount'.tr(),
                              hint: 'debt_amount_hint'.tr(),
                              controller: balanceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixIconData: Icons.payments_outlined,
                              validator: AppValidators.amount,
                            )
                          : SizedBox.shrink(),
                      HeightSpace(24),

                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButtonWidget(
                              iconData: Icons.cancel_outlined,
                              iconeColor: Colors.white,
                              textColor: Colors.white,
                              fontSize: 16.sp,
                              iconSize: 20.sp,
                              buttonColor: context.colors.error,
                              buttonText: isLoading ? ''.tr() : 'cancel'.tr(),
                              borderRadius: AppRadius.sm,
                              onPress: isLoading ? null : () => context.pop(),
                            ),
                          ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: PrimaryButtonWidget(
                              iconData: Icons.save,
                              iconSize: 20.sp,
                              iconeColor: Colors.white,
                              textColor: Colors.white,
                              fontSize: 16.sp,
                              buttonText: isLoading ? ''.tr() : 'save'.tr(),
                              borderRadius: AppRadius.sm,
                              onPress: isLoading ? null : _onSave,
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
      },
    );
  }
}
