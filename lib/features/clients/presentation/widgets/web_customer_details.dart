part of '../layout/web_client.dart';

class _CustomerDetailsPanel extends StatelessWidget {
  const _CustomerDetailsPanel({
    required this.customer,
    required this.onPayDebt,
  });

  final CustomerModel? customer;
  final ValueChanged<CustomerModel> onPayDebt;

  @override
  Widget build(BuildContext context) {
    if (customer == null) {
      return const _EmptyCustomerDetails();
    }

    final CustomerModel selected = customer!;
    final num balance = selected.balance ?? 0;
    final bool hasDebt = selected.hasDebt == true;
    final String address = selected.address?.trim().isNotEmpty == true
        ? selected.address!.trim()
        : 'not_available'.tr();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 22,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'customer_details'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: context.colors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selected.name ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.phone_outlined,
              title: 'phone'.tr(),
              value: selected.phone ?? '-',
            ),
            const SizedBox(height: 9),
            _InfoRow(
              icon: Icons.location_on_outlined,
              title: 'address'.tr(),
              value: address,
            ),
            const SizedBox(height: 16),
            _DebtSummaryCard(
              balance: balance,
              hasDebt: hasDebt,
              onPay: hasDebt ? () => onPayDebt(selected) : null,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'recent_invoices'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (selected.id != null)
                  TextButton(
                    onPressed: () {
                      context.pushNamed(
                        AppRoutes.allClientInvoicesScreen,
                        extra: selected.id,
                      );
                    },
                    child: Text(
                      'show_all'.tr(),
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            if (selected.id != null)
              InvoiceList(customerId: selected.id!),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    title: 'total_purchases'.tr(),
                    value: selected.totalPurchases.toString(),
                    icon: Icons.trending_up_rounded,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _MiniStat(
                    title: 'order_count'.tr(),
                    value: selected.orderCount.toString(),
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CustomerMapCard(
              height: 145,
              borderRadius: 14,
              image: Image.asset(
                AppAssets.map,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            const _DeliveryOrdersPlaceholder(),
          ],
        ),
      ),
    );
  }
}
