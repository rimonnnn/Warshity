part of '../layout/web_client.dart';

class _CustomerTableRow extends StatelessWidget {
  const _CustomerTableRow({
    required this.customer,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final CustomerModel customer;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = customer.hasDebt == true;
    final num balance = customer.balance ?? 0;
    final String address = customer.address?.trim().isNotEmpty == true
        ? customer.address!.trim()
        : '-';

    return Material(
      color: selected
          ? context.colors.primary.withValues(alpha: .035)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: context.colors.outlineVariant.withValues(alpha: .55),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                alignment: Alignment.center,
                child: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 16,
                  color: selected
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant.withValues(alpha: .35),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: .09),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        customer.name ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  customer.phone ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: context.colors.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: context.colors.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  customer.orderCount.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: _StatusBadge(
                  hasDebt: hasDebt,
                  amount: balance.toString(),
                ),
              ),
              SizedBox(
                width: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 17,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 7),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 17,
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.hasDebt,
    required this.amount,
  });

  final bool hasDebt;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final Color color = hasDebt ? context.colors.error : Colors.green;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        constraints: const BoxConstraints(
          minHeight: 28,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: .38),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasDebt
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                hasDebt
                    ? _tr(
                        context,
                        'customer_debt',
                        ar: 'مديونية {0} ج.م',
                        en: 'Debt: {0} EGP',
                        args: [amount],
                      )
                    : _tr(
                        context,
                        'customer_balance',
                        ar: 'حساب متزن: {0} ج.م',
                        en: 'Balanced: {0}',
                        args: [amount],
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
