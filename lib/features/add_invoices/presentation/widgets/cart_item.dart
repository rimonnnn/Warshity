import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
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

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(AppPadding.sm),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerLow,
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
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            size: 20,
            color: context.colors.onPrimaryContainer,
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
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const HeightSpace(2),
              Text(
                '\$${unitPrice.toStringAsFixed(2)} × $quantity',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
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
                color: context.colors.primary,
              ),
            ),
            const HeightSpace(6),
            _QuantityStepper(
              quantity: quantity,
              onIncrement: onQuantityChanged != null
                  ? () => onQuantityChanged!(quantity + 1)
                  : null,
              onDecrement: onQuantityChanged != null || onDelete != null
                  ? _handleDecrement
                  : null,
            ),
          ],
        ),
      ],
    ),
  );
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
    final atMinimum = quantity <= 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.sm,
        ), // add `pill` to AppRadius, or use circular(20)
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: atMinimum ? Icons.delete_outline : Icons.remove,
            tooltip: atMinimum ? 'Remove item' : 'Decrease quantity',
            onPressed: onDecrement,
            foreground: atMinimum
                ? context.colors.error
                : context.colors.onSurfaceVariant,
          ),
          SizedBox(
            width: 22,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_box,
            tooltip: 'Increase quantity',
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
    final disabled = onPressed == null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled && !disabled
            ? context.colors.primary
            : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(
              icon,
              size: 20,
              color: disabled
                  ? context.colors.onSurfaceVariant.withValues(alpha: 0.35)
                  : filled
                  ? context.colors.onPrimary
                  : foreground ?? context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
