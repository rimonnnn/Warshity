import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? Icon(
              Icons.inventory_2_outlined,
              color: context.colors.onSurfaceVariant,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Icon(
                  Icons.image_not_supported_outlined,
                  color: context.colors.onSurfaceVariant,
                );
              },
            ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category.isEmpty ? '-' : category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class QuantityControls extends StatelessWidget {
  const QuantityControls({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onEdit,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        QuantityButton(icon: Icons.remove, onTap: onDecrease),

        SizedBox(
          width: 38,
          child: Center(
            child: Text(
              '$quantity',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        QuantityButton(icon: Icons.add, onTap: onIncrease, primary: true),

        const SizedBox(width: 4),

        IconButton(
          onPressed: onEdit,
          tooltip: 'edit'.tr(),
          icon: const Icon(Icons.edit_outlined, size: 17),
        ),
      ],
    );
  }
}

class QuantityButton extends StatelessWidget {
  const QuantityButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 27,
        height: 27,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null
              ? context.colors.surfaceContainerLow
              : primary
              ? context.colors.primary.withValues(alpha: 0.10)
              : context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 15,
          color: onTap == null
              ? context.colors.outline
              : primary
              ? context.colors.primary
              : context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class HeaderText extends StatelessWidget {
  const HeaderText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}
