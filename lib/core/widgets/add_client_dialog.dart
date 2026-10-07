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
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/presentation/cubit/add_client_cubit.dart';

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
            message: 'client_added_successfully'.tr(),
            type: AnimatedSnackBarType.success,
          );
        }

        if (state is AddClientError) {
          showAnimatedSnackDialog(
            context,
            message: 'something_error'.tr(),
            type: AnimatedSnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is AddClientLoading;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = MediaQuery.sizeOf(context).width;
            final double screenHeight = MediaQuery.sizeOf(context).height;

            final bool isMobile = screenWidth < 600;
            final bool isSmallMobile = screenWidth < 380;

            final double dialogWidth = isMobile
                ? (screenWidth - 32).clamp(280.0, 560.0)
                : 560.0;

            final double horizontalPadding = isSmallMobile ? 16 : 22;
            final double verticalPadding = isSmallMobile ? 16 : 20;

            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 20 : 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: context.colors.outlineVariant),
              ),
              // surfaceContainer بدل surface، عشان الـ dialog يبان فوق الخلفية
              backgroundColor: context.colors.surfaceContainer,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 280,
                  maxWidth: dialogWidth,
                  maxHeight: screenHeight - (isMobile ? 40 : 80),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: isMobile ? 44 : 48,
                                height: isMobile ? 44 : 48,
                                decoration: BoxDecoration(
                                  color: context.colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: isMobile ? 21 : 23,
                                  color: context.colors.primary,
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'add_client'.tr(),
                                    style: context.text.titleLarge?.copyWith(
                                      fontSize: isMobile ? 20 : 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context.pop(),
                                tooltip: 'cancel'.tr(),
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          CustomTextField(
                            iconSize: isMobile ? 18.sp : 19,
                            label: 'client_name'.tr(),
                            hint: 'client_name_hint'.tr(),
                            prefixIconData: Icons.person_outline_rounded,
                            controller: nameController,
                            keyboardType: TextInputType.name,
                            validator: AppValidators.clientName,
                          ),

                          const SizedBox(height: 14),

                          CustomTextField(
                            iconSize: isMobile ? 18.sp : 19,
                            label: 'phone'.tr(),
                            hint: 'phone_hint'.tr(),
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            validator: AppValidators.phone,
                            prefixIconData: Icons.phone_outlined,
                          ),

                          const SizedBox(height: 14),

                          CustomTextField(
                            iconSize: isMobile ? 18.sp : 19,
                            label: 'address'.tr(),
                            hint: 'address_hint'.tr(),
                            controller: addressController,
                            keyboardType: TextInputType.streetAddress,
                            prefixIconData: Icons.location_on_outlined,
                            validator: AppValidators.address,
                          ),

                          const SizedBox(height: 14),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              // أغمق من الـ dialog عشان يظهر كمنطقة منفصلة
                              color: context.colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.colors.outlineVariant,
                              ),
                            ),
                            child: CustomerBalanceType(
                              value: hasDebt,
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        hasDebt = value;
                                      });
                                    },
                            ),
                          ),

                          if (hasDebt) ...[
                            const SizedBox(height: 14),
                            CustomTextField(
                              iconSize: isMobile ? 18.sp : 19,
                              label: 'debt_amount'.tr(),
                              hint: 'debt_amount_hint'.tr(),
                              controller: balanceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixIconData: Icons.payments_outlined,
                              validator: AppValidators.amount,
                            ),
                          ],

                          const SizedBox(height: 20),

                          BlocBuilder<AddClientCubit, AddClientState>(
                            buildWhen: (previous, current) {
                              final bool previousLoading =
                                  previous is AddClientLoading;
                              final bool currentLoading =
                                  current is AddClientLoading;

                              return previousLoading != currentLoading;
                            },
                            builder: (context, state) {
                              final bool loading = state is AddClientLoading;

                              if (isSmallMobile) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    PrimaryButtonWidget(
                                      iconData: Icons.cancel_outlined,
                                      iconeColor: context.colors.onError,
                                      textColor: context.colors.onError,
                                      fontSize: 13,
                                      iconSize: 18,
                                      buttonColor: context.colors.error,
                                      buttonText: loading ? '' : 'cancel'.tr(),
                                      borderRadius: AppRadius.sm,
                                      onPress: loading
                                          ? null
                                          : () => context.pop(),
                                    ),
                                    const SizedBox(height: 9),
                                    PrimaryButtonWidget(
                                      iconData: Icons.save_outlined,
                                      iconSize: 18,
                                      iconeColor: context.colors.onPrimary,
                                      textColor: context.colors.onPrimary,
                                      fontSize: 13,
                                      buttonText: loading ? '' : 'save'.tr(),
                                      borderRadius: AppRadius.sm,
                                      onPress: loading ? null : _onSave,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: PrimaryButtonWidget(
                                      iconData: Icons.cancel_outlined,
                                      iconeColor: context.colors.onError,
                                      textColor: context.colors.onError,
                                      fontSize: isMobile ? 13 : 14,
                                      iconSize: isMobile ? 18 : 19,
                                      buttonColor: context.colors.error,
                                      buttonText: loading ? '' : 'cancel'.tr(),
                                      borderRadius: AppRadius.sm,
                                      onPress: loading
                                          ? null
                                          : () => context.pop(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: PrimaryButtonWidget(
                                      iconData: Icons.save_outlined,
                                      iconSize: isMobile ? 18 : 19,
                                      iconeColor: context.colors.onPrimary,
                                      textColor: context.colors.onPrimary,
                                      fontSize: isMobile ? 13 : 14,
                                      buttonText: loading ? '' : 'save'.tr(),
                                      borderRadius: AppRadius.sm,
                                      onPress: loading ? null : _onSave,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          if (isLoading) ...[
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(10),
                              color: context.colors.primary,
                              backgroundColor: context.colors.primaryContainer,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
