import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class InvoiceCustomerCard extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback onTap;

  final String? selectedCustomerName;
  final VoidCallback? onClearCustomer;

  const InvoiceCustomerCard({
    super.key,
    required this.onTap,
    this.onSearchChanged,
    this.selectedCustomerName,
    this.onClearCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelectedCustomer =
        selectedCustomerName != null &&
        selectedCustomerName!.isNotEmpty;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppPadding.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.sm,
          vertical: AppPadding.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasSelectedCustomer)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: const Icon(Icons.person),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        selectedCustomerName!,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: onClearCustomer,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(
                    AppRadius.sm,
                  ),
                ),
                child: CustomTextField(
                  hint: 'search_clients'.tr(),
                  prefixIcon: AppAssets.searchIcon,
                  onChanged: onSearchChanged ?? (_) {},
                  borderRadius: AppRadius.md,
                  height: 48,
                ),
              ),

            HeightSpace(8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'customer'.tr(),
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppRadius.sm,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 16,
                          color: context.colors.onPrimaryContainer,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          'add_client'.tr(),
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onPrimaryContainer,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}