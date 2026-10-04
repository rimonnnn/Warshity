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
import 'package:warshity/features/clients/presentation/cubit/debt_cubit.dart';

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
      child: LayoutBuilder(
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

          final double titleSize = isMobile ? 20 : 21;
          final double bodySize = isMobile ? 13 : 14;

          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 20 : 28,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            backgroundColor: context.colors.surface,
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
                          children: [
                            Container(
                              width: isMobile ? 42 : 46,
                              height: isMobile ? 42 : 46,
                              decoration: BoxDecoration(
                                color: context.colors.primary.withValues(
                                  alpha: .10,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                size: isMobile ? 21 : 23,
                                color: context.colors.primary,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                'decrease_debt'.tr(),
                                textAlign: TextAlign.start,
                                style: context.text.titleLarge?.copyWith(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: isMobile ? 11 : 12,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.error.withValues(alpha: .06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.colors.error.withValues(
                                alpha: .20,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: isMobile ? 18.sp : 19,
                                color: context.colors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'current_debt'.tr(),
                                  style: context.text.bodyMedium?.copyWith(
                                    fontSize: bodySize - 1,
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${widget.currentBalance} ${'EGP'.tr()}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleMedium?.copyWith(
                                    fontSize: isMobile ? 16 : 17,
                                    color: context.colors.error,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'debt_payment_amount'.tr(),
                          hint: 'debt_payment_amount_hint'.tr(),
                          iconSize: isMobile ? 18.sp : 19,
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIconData: Icons.payments_outlined,
                          validator: _validateAmount,
                        ),

                        const SizedBox(height: 18),

                        BlocBuilder<DebtCubit, DebtState>(
                          buildWhen: (previous, current) {
                            if (previous is DebtAction &&
                                current is DebtAction) {
                              return previous.status != current.status;
                            }

                            return current is DebtAction;
                          },
                          builder: (context, state) {
                            final bool isLoading =
                                state is DebtAction &&
                                state.status == DebtActionStatus.loading;

                            if (isSmallMobile) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  PrimaryButtonWidget(
                                    iconData: Icons.cancel_outlined,
                                    iconeColor: context.colors.errorContainer,
                                    fontSize: 13,
                                    iconSize: 18,
                                    buttonColor: context.colors.error,
                                    buttonText: 'cancel'.tr(),
                                    borderRadius: AppRadius.sm,
                                    onPress: isLoading
                                        ? null
                                        : () => context.pop(),
                                  ),
                                  const SizedBox(height: 9),
                                  PrimaryButtonWidget(
                                    iconData: Icons.save_outlined,
                                    iconSize: 18,
                                    iconeColor: context.colors.primaryContainer,
                                    fontSize: 13,
                                    buttonText: isLoading ? '' : 'save'.tr(),
                                    borderRadius: AppRadius.sm,
                                    onPress: isLoading ? null : _onSave,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: PrimaryButtonWidget(
                                    iconData: Icons.cancel_outlined,
                                    iconeColor: context.colors.errorContainer,
                                    fontSize: isMobile ? 13 : 14,
                                    iconSize: isMobile ? 18 : 20,
                                    buttonColor: context.colors.error,
                                    buttonText: 'cancel'.tr(),
                                    borderRadius: AppRadius.sm,
                                    onPress: isLoading
                                        ? null
                                        : () => context.pop(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: PrimaryButtonWidget(
                                    iconData: Icons.save_outlined,
                                    iconSize: isMobile ? 18 : 20,
                                    iconeColor: context.colors.primaryContainer,
                                    fontSize: isMobile ? 13 : 14,
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
        },
      ),
    );
  }
}
