import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/add_product_button.dart';

class InvoiceSearchBar extends StatelessWidget {
  const InvoiceSearchBar({super.key, this.onSearchChanged,required this.onAddProduct});

  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.md, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextField(
            hint: 'search_products'.tr(),
            prefixIcon: AppAssets.searchIcon,
            onChanged: onSearchChanged ?? (_) {},
            borderRadius: AppRadius.md,
            height: 48,
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomLeft,
            child: AddProductButton(onTap: onAddProduct),
          ),
        ],
      ),
    );
  }
}
