import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';

class WebCreateInvoiceButton extends StatelessWidget {
  const WebCreateInvoiceButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        final isLoading = state is InvoiceLoading;

        return PrimaryButtonWidget(
          buttonText: 'create_invoice'.tr(),
          iconData: Icons.receipt_long_outlined,
          iconeColor: context.colors.onPrimary,
          buttonColor: context.colors.primary,
          height: 56,
          fontSize: 18,
          isLoading: isLoading,
          onPress: isLoading ? null : onPressed,
        );
      },
    );
  }
}
