import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';

import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';

class InvoiceSearchBar extends StatelessWidget {
  const InvoiceSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: 8.h,
      ),
      child: CustomTextField(
        hint: 'search_invoice'.tr(),
        prefixIcon: AppAssets.searchIcon,
        onChanged: (value) {
          context
              .read<InvoiceHistoryCubit>()
              .searchInvoices(value);
        },
      ),
    );
  }
}