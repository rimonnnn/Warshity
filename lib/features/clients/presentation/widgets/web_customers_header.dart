part of '../layout/web_client.dart';

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.count,
    required this.onAdd,
  });

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: context.colors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'customers'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'search_client'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '$count ${'customers'.tr()}',
              style: TextStyle(
                color: context.colors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 19,
            ),
            label: Text(
              'new_customer'.tr(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.customers,
  });

  final List<CustomerModel> customers;

  @override
  Widget build(BuildContext context) {
    final List<CustomerModel> debtCustomers = customers
        .where((customer) => customer.hasDebt == true)
        .toList();

    final int balancedCustomers =
        customers.where((customer) => customer.hasDebt != true).length;

    final num totalDebt = debtCustomers.fold<num>(
      0,
      (sum, customer) => sum + (customer.balance ?? 0),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 680
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.75,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: 'total_customer_debt'.tr(),
              value:
                  '${totalDebt.toStringAsFixed(0)} ${'EGP'.tr()}',
              subtitle: 'total_debt'.tr(),
              icon: Icons.account_balance_wallet_outlined,
              iconColor: context.colors.error,
            ),
            _StatCard(
              title: 'debt'.tr(),
              value: debtCustomers.length.toString(),
              subtitle: 'customers'.tr(),
              icon: Icons.person_outline_rounded,
              iconColor: Colors.orange,
            ),
            _StatCard(
              title: 'balanced_customers'.tr(),
              value: balancedCustomers.toString(),
              subtitle: 'customers'.tr(),
              icon: Icons.verified_outlined,
              iconColor: Colors.teal,
            ),
            _StatCard(
              title: 'delivery_orders'.tr(),
              value: '0',
              subtitle: 'waiting_customers'.tr(),
              icon: Icons.local_shipping_outlined,
              iconColor: Colors.cyan,
            ),
          ],
        );
      },
    );
  }
}
