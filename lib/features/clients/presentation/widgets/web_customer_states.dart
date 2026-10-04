part of '../layout/web_client.dart';

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _EmptyTableContent extends StatelessWidget {
  const _EmptyTableContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 54,
      ),
      color: context.colors.surface,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_outlined,
              size: 30,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _tr(
              context,
              'no_customers',
              ar: 'لا يوجد عملاء',
              en: 'No customers',
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            _tr(
              context,
              'empty_filter',
              ar: 'لا توجد نتائج مطابقة للفلاتر الحالية',
              en: 'No customers match the current filter',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCustomerDetails extends StatelessWidget {
  const _EmptyCustomerDetails();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 360,
      ),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_outlined,
              size: 34,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _tr(
              context,
              'select_customer',
              ar: 'اختر عميلاً',
              en: 'Select a customer',
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _tr(
              context,
              'select_customer_hint',
              ar: 'حدد عميلاً من الجدول لعرض تفاصيله',
              en: 'Select a customer from the table to view details',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOrdersPlaceholder extends StatelessWidget {
  const _DeliveryOrdersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr(
                    context,
                    'delivery_orders',
                    ar: 'طلبات التوصيل المنتظرة',
                    en: 'Pending Delivery Orders',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _tr(
                    context,
                    'waiting_customers',
                    ar: '0 عملاء بانتظار الاستلام',
                    en: '0 customers waiting for delivery',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_left_rounded,
          ),
        ],
      ),
    );
  }
}
