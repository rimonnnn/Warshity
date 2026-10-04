import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';

BoxDecoration productContainerDecoration(BuildContext context) {
  return BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: context.colors.outlineVariant),
  );
}

String formatMoney(double value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}

Future<void> deleteProduct(BuildContext context, ProductModel product) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Delete Product'.tr()),
        content: Text(
          '${"Are you sure you want to delete".tr()} ${product.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: Text('Cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: Text(
              'Delete'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await context.read<ProductsCubit>().deleteProduct(product.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('product_deleted_successfully'.tr())),
    );
  } catch (_) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('failed_to_delete_product'.tr())));
  }
}
