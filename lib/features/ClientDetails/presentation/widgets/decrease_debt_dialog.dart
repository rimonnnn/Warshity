import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/presentation/cubit/debt_cubit.dart';

class DecreaseDebtDialog extends StatefulWidget {
  final String clientId;
  final num currentBalance;

  const DecreaseDebtDialog({
    super.key,
    required this.clientId,
    required this.currentBalance,
  });

  @override
  State<DecreaseDebtDialog> createState() => _DecreaseDebtDialogState();
}

class _DecreaseDebtDialogState extends State<DecreaseDebtDialog> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final error = AppValidators.amount(value);

    if (error != null) {
      return error;
    }

    final amount = num.tryParse(value!.trim());

    if (amount == null || amount <= 0) {
      return 'debt_payment_must_be_greater_than_zero'.tr();
    }

    if (amount > widget.currentBalance) {
      return 'debt_payment_exceeds_balance'.tr();
    }

    return null;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final amount = num.parse(amountController.text.trim());

    context.read<DebtCubit>().decreaseDebt(
      clientId: widget.clientId,
      amount: amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DebtCubit, DebtState>(
      listenWhen: (previous, current) {
        if (previous is DebtAction && current is DebtAction) {
          return previous.status != current.status;
        }

        return current is DebtAction;
      },
      listener: (context, state) {
        if (state is! DebtAction) return;

        switch (state.status) {
          case DebtActionStatus.initial:
            break;

          case DebtActionStatus.loading:
            break;

          case DebtActionStatus.success:
            context.pop();
            break;

          case DebtActionStatus.failure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'something_error'.tr()),
              ),
            );
            break;
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        backgroundColor: context.colors.surface,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'decrease_debt'.tr(),
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  HeightSpace(8),

                  Text(
                    '${widget.currentBalance}',
                    style: context.text.titleMedium?.copyWith(
                      color: context.colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  HeightSpace(16),

                  CustomTextField(
                    label: 'debt_payment_amount'.tr(),
                    hint: 'debt_payment_amount_hint'.tr(),
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIconData: Icons.payments_outlined,
                    validator: _validateAmount,
                  ),

                  HeightSpace(16),

                  BlocBuilder<DebtCubit, DebtState>(
                    buildWhen: (previous, current) {
                      if (previous is DebtAction && current is DebtAction) {
                        return previous.status != current.status;
                      }

                      return current is DebtAction;
                    },
                    builder: (context, state) {
                      final isLoading =
                          state is DebtAction &&
                          state.status == DebtActionStatus.loading;

                      return Row(
                        children: [
                          Expanded(
                            child: PrimaryButtonWidget(
                              iconData: Icons.cancel_outlined,
                              iconeColor: context.colors.errorContainer,
                              fontSize: 14.sp,
                              iconSize: 20.sp,
                              buttonColor: context.colors.error,
                              buttonText: 'cancel'.tr(),
                              borderRadius: AppRadius.sm,
                              onPress: isLoading ? null : () => context.pop(),
                            ),
                          ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: PrimaryButtonWidget(
                              iconData: Icons.save,
                              iconSize: 20.sp,
                              iconeColor: context.colors.primaryContainer,
                              fontSize: 14.sp,
                              buttonText: isLoading ? '' : 'save'.tr(),
                              borderRadius: AppRadius.sm,
                              onPress: isLoading ? null : _onSave,
                            ),
                          ),
                        ],
                      );
                    },
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
