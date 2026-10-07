import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/quantity_bottom_sheet.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
    required this.productName,
    required this.unitPrice,
    this.quantity = 1,
    this.onQuantityChanged,
    this.onDelete,
  });

  final String productName;
  final double unitPrice;
  final int quantity;
  final void Function(int)? onQuantityChanged;
  final VoidCallback? onDelete;

  double get _subtotal => unitPrice * quantity;

  void _handleDecrement() {
    if (quantity <= 1) {
      onDelete?.call();
    } else {
      onQuantityChanged?.call(quantity - 1);
    }
  }

  Future<void> _showQuantityBottomSheet(BuildContext context) async {
    if (onQuantityChanged == null) {
      return;
    }

    await QuantityBottomSheet.show(
      context: context,
      quantity: quantity,
      onQuantityChanged: (newQuantity) async {
        onQuantityChanged?.call(newQuantity);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Container(
      padding: EdgeInsets.all(AppPadding.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 20,
              // primary: نفس لون أيقونات باقي الشاشات فوق primaryContainer
              color: scheme.primary,
            ),
          ),

          WidthSpace(AppPadding.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: context.text.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const HeightSpace(2),
                Text(
                  '\$${unitPrice.toStringAsFixed(2)} × $quantity',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          WidthSpace(AppPadding.sm),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${_subtotal.toStringAsFixed(2)}',
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),

              const HeightSpace(6),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuantityStepper(
                    quantity: quantity,
                    onIncrement: onQuantityChanged != null
                        ? () => onQuantityChanged!(quantity + 1)
                        : null,
                    onDecrement: onQuantityChanged != null || onDelete != null
                        ? _handleDecrement
                        : null,
                  ),

                  const SizedBox(width: 2),

                  // IconButton بدل GestureDetector: ripple + tooltip + مساحة لمس 40px
                  IconButton(
                    onPressed: () {
                      _showQuantityBottomSheet(context);
                    },
                    tooltip: 'quantity'.tr(),
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final atMinimum = quantity <= 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: atMinimum ? Icons.delete_outline : Icons.remove,
            tooltip: atMinimum ? 'remove_item'.tr() : 'decrease_quantity'.tr(),
            onPressed: onDecrement,
            foreground: atMinimum ? scheme.error : scheme.onSurfaceVariant,
          ),

          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          _StepperButton(
            // Icons.add بدل add_box: دايرة فيها علامة + بدل مربع جوه دايرة
            icon: Icons.add,
            tooltip: 'increase_quantity'.tr(),
            onPressed: onIncrement,
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.foreground,
    this.filled = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? foreground;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final disabled = onPressed == null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled && !disabled ? scheme.primary : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            // 32 بدل 28: مساحة لمس أكبر من غير ما الـ stepper يكبر كتير
            width: 32,
            height: 32,
            child: Icon(
              icon,
              size: 18,
              color: disabled
                  ? scheme.onSurfaceVariant.withValues(alpha: 0.35)
                  : filled
                  ? scheme.onPrimary
                  : foreground ?? scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
