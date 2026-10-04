part of '../layout/web_client.dart';

class _DebtSummaryCard extends StatelessWidget {
  const _DebtSummaryCard({
    required this.balance,
    required this.hasDebt,
    required this.onPay,
  });

  final num balance;
  final bool hasDebt;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        hasDebt ? context.colors.error : context.colors.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(14),
        border: BorderDirectional(
          end: BorderSide(
            color: accent,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'current_debt'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: context.colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${balance.toString()} ${'EGP'.tr()}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
          ),
          if (hasDebt) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: FilledButton.icon(
                onPressed: onPay,
                icon: const Icon(
                  Icons.payments_outlined,
                  size: 17,
                ),
                label: Text(
                  'pay_debt'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: context.colors.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 17,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: context.colors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
