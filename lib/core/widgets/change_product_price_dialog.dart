import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';

/// Opens a responsive dialog to change only the product's current catalog price.
/// Saved invoices keep their own item prices and are not modified by this update.
Future<void> showChangeProductPriceDialog({
  required BuildContext context,
  required ProductModel product,
}) async {
  final productsCubit = context.read<ProductsCubit>();

  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ChangeProductPriceDialog(
      product: product,
      productsCubit: productsCubit,
    ),
  );

  if (saved == true && context.mounted) {
    showAnimatedSnackDialog(
      context,
      message: 'product_price_updated_successfully'.tr(),
      type: AnimatedSnackBarType.success,
    );
  }
}

class _ChangeProductPriceDialog extends StatefulWidget {
  const _ChangeProductPriceDialog({
    required this.product,
    required this.productsCubit,
  });

  final ProductModel product;
  final ProductsCubit productsCubit;

  @override
  State<_ChangeProductPriceDialog> createState() =>
      _ChangeProductPriceDialogState();
}

class _ChangeProductPriceDialogState extends State<_ChangeProductPriceDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final price = widget.product.price;

    _controller = TextEditingController(
      text: price % 1 == 0 ? price.toInt().toString() : price.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _savePrice() async {
    if (_isSaving) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final newPrice = double.parse(_controller.text.trim());

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.productsCubit.updateProductPrice(
        productId: widget.product.id,
        price: newPrice,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage = 'failed_to_update_product_price'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.price_change_outlined,
                      color: colors.primary,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'change_product_price'.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 20),

                _buildCurrentPrice(colors),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  enabled: !_isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'new_price'.tr(),
                    prefixIcon: const Icon(Icons.payments_outlined),
                    suffixText: 'EGP'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value?.trim() ?? '');

                    if (parsed == null || !parsed.isFinite || parsed < 0) {
                      return 'enter_valid_price'.tr();
                    }

                    return null;
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: TextStyle(color: colors.error)),
                ],

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text('Cancel'.tr()),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _savePrice,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text('Save'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPrice(ColorScheme colors) {
    final price = widget.product.price;

    final formattedPrice = price % 1 == 0
        ? price.toInt().toString()
        : price.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('current_price'.tr()),
          const SizedBox(height: 4),
          Text(
            '$formattedPrice ${'EGP'.tr()}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
