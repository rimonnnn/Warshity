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
                  _tr(
                    context,
                    'customers',
                    ar: 'العملاء',
                    en: 'Customers',
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tr(
                    context,
                    'search_client',
                    ar: 'إبحث باسم العميل أو رقم الهاتف...',
                    en: 'Search by customer name or phone number...',
                  ),
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
              '$count ${_tr(context, 'customers', ar: 'العملاء', en: 'Customers')}',
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
              _tr(
                context,
                'new_customer',
                ar: 'عميل جديد',
                en: 'New Customer',
              ),
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
              title: _tr(
                context,
                'total_customer_debt',
                ar: 'إجمالي مديونيات العملاء',
                en: 'Total Customer Debt',
              ),
              value:
                  '${totalDebt.toStringAsFixed(0)} ${_tr(context, 'EGP', ar: 'ج.م', en: 'EGP')}',
              subtitle: _tr(
                context,
                'customer_debt',
                ar: 'إجمالي المديونية',
                en: 'Customer debt',
              ),
              icon: Icons.account_balance_wallet_outlined,
              iconColor: context.colors.error,
            ),
            _StatCard(
              title: _tr(
                context,
                'debt',
                ar: 'مديونية',
                en: 'Debt',
              ),
              value: debtCustomers.length.toString(),
              subtitle: _tr(
                context,
                'customers',
                ar: 'العملاء',
                en: 'Customers',
              ),
              icon: Icons.person_outline_rounded,
              iconColor: Colors.orange,
            ),
            _StatCard(
              title: _tr(
                context,
                'balanced_customers',
                ar: 'حساب متزن',
                en: 'Balanced Accounts',
              ),
              value: balancedCustomers.toString(),
              subtitle: _tr(
                context,
                'customers',
                ar: 'العملاء',
                en: 'Customers',
              ),
              icon: Icons.verified_outlined,
              iconColor: Colors.teal,
            ),
            _StatCard(
              title: _tr(
                context,
                'delivery_orders',
                ar: 'طلبات التوصيل المنتظرة',
                en: 'Pending Delivery Orders',
              ),
              value: '0',
              subtitle: _tr(
                context,
                'waiting_customers',
                ar: '0 عملاء بانتظار الاستلام',
                en: '0 customers waiting for delivery',
              ),
              icon: Icons.local_shipping_outlined,
              iconColor: Colors.cyan,
            ),
          ],
        );
      },
    );
  }
}
