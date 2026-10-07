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
    final scheme = context.colors;

    final hasSelectedCustomer =
        selectedCustomerName != null && selectedCustomerName!.isNotEmpty;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppPadding.sm),
      // تحديد shape هنا بيلغي حد الـ cardTheme، فبنرجعه
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(AppPadding.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان وزر إضافة عميل فوق، قبل الحقل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'customer'.tr(),
                  style: context.text.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Material(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: scheme.primary.withValues(alpha: 0.12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 40),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_add,
                              size: 18,
                              color: scheme.primary,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              'add_client'.tr(),
                              style: context.text.bodyMedium?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            HeightSpace(12),

            if (hasSelectedCustomer)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  // حد primary خفيف يوضح إن فيه عميل مختار
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.primary,
                      child: const Icon(Icons.person),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        selectedCustomerName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: onClearCustomer,
                      tooltip: 'cancel'.tr(),
                      icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            else
              // الحقل ليه fill وحد خاصين بيه، فمفيش داعي للـ Container اللي حواليه
              CustomTextField(
                hint: 'search_clients'.tr(),
                prefixIcon: AppAssets.searchIcon,
                onChanged: onSearchChanged ?? (_) {},
                borderRadius: AppRadius.md,
                height: 48,
              ),
          ],
        ),
      ),
    );
  }
}
