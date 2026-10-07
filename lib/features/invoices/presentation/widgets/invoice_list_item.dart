import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_table_row.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_status_utils.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_badge.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_actions.dart';

class InvoiceHistoryRow extends StatelessWidget {
  const InvoiceHistoryRow({
    super.key,
    required this.invoice,
    required this.selectedId,
    required this.onSelect,
  });

  final InvoiceModel invoice;
  final String? selectedId;
  final ValueChanged<InvoiceModel> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = invoice.invoiceId == selectedId;

    return InvoiceRow(
      selected: selected,
      onTap: () => onSelect(invoice),
      cells: [
        Text(
          '#${invoice.invoiceId ?? ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          invoice.customerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium,
        ),
        Text(
          InvoiceWebActions.formatDate(invoice.createdAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium,
        ),
        Text(
          '${invoice.items.length}',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: context.text.bodyMedium,
        ),
        Text(
          money(invoice.total),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          money(invoice.remainingAmount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium?.copyWith(
            color: invoice.remainingAmount > 0
                ? colors.error
                : colors.onSurfaceVariant,
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: InvoiceStatusBadge(status: invoiceStatusOf(invoice)),
        ),
      ],
    );
  }
}
