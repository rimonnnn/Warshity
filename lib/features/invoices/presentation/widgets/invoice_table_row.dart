import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

/// Column flex values shared by the header row and the data rows.
const invoiceTableFlex = [3, 3, 3, 2, 2, 2, 2];

class InvoiceRow extends StatelessWidget {
  const InvoiceRow({
    super.key,
    required this.cells,
    this.header = false,
    this.selected = false,
    this.background,
    this.onTap,
  });

  final List<Widget> cells;
  final bool header;
  final bool selected;
  final Color? background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.14)
          : (background ?? Colors.transparent),
      child: InkWell(
        onTap: onTap,
        hoverColor: header
            ? Colors.transparent
            : colors.primary.withValues(alpha: 0.06),
        splashColor: colors.primary.withValues(alpha: 0.08),

        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: header ? 10 : 14,
          ),
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(
                color: selected ? colors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                Expanded(flex: invoiceTableFlex[i], child: cells[i]),
                if (i != cells.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
