part of '../layout/web_client.dart';

class _MainCustomersArea extends StatelessWidget {
  const _MainCustomersArea({
    required this.customers,
    required this.selectedCustomer,
    required this.selectedCustomerIndex,
    required this.onSelectCustomer,
    required this.onDeleteCustomer,
    required this.onPayDebt,
  });

  final List<CustomerModel> customers;
  final CustomerModel? selectedCustomer;
  final int selectedCustomerIndex;
  final ValueChanged<int> onSelectCustomer;
  final ValueChanged<CustomerModel> onDeleteCustomer;
  final ValueChanged<CustomerModel> onPayDebt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 980;

        if (!wide) {
          return Column(
            children: [
              _CustomersTable(
                customers: customers,
                selectedCustomerIndex: selectedCustomerIndex,
                onSelectCustomer: onSelectCustomer,
                onDeleteCustomer: onDeleteCustomer,
              ),
              const SizedBox(height: 16),
              _CustomerDetailsPanel(
                customer: selectedCustomer,
                onPayDebt: onPayDebt,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _CustomersTable(
                customers: customers,
                selectedCustomerIndex: selectedCustomerIndex,
                onSelectCustomer: onSelectCustomer,
                onDeleteCustomer: onDeleteCustomer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _CustomerDetailsPanel(
                customer: selectedCustomer,
                onPayDebt: onPayDebt,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CustomersTable extends StatelessWidget {
  const _CustomersTable({
    required this.customers,
    required this.selectedCustomerIndex,
    required this.onSelectCustomer,
    required this.onDeleteCustomer,
  });

  final List<CustomerModel> customers;
  final int selectedCustomerIndex;
  final ValueChanged<int> onSelectCustomer;
  final ValueChanged<CustomerModel> onDeleteCustomer;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          _TableHeader(),
          if (customers.isEmpty)
            const _EmptyTableContent()
          else
            ...List<Widget>.generate(
              customers.length,
              (index) {
                return _CustomerTableRow(
                  customer: customers[index],
                  index: index,
                  selected: index == selectedCustomerIndex,
                  onTap: () => onSelectCustomer(index),
                  onDelete: () => onDeleteCustomer(customers[index]),
                );
              },
            ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(
                top: BorderSide(
                  color: context.colors.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${_tr(context, 'customers', ar: 'العملاء', en: 'Customers')}: ${customers.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: context.colors.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                Text(
                  '1',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: context.colors.primary,
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

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      color: context.colors.primary.withValues(alpha: .045),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Expanded(
            flex: 3,
            child: Text(
              _tr(
              context,
              'customer',
              ar: 'العميل',
              en: 'Customer',
            ),
              style: _tableHeaderStyle(context),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _tr(
              context,
              'phone',
              ar: 'رقم الهاتف',
              en: 'Phone',
            ),
              style: _tableHeaderStyle(context),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _tr(
              context,
              'address',
              ar: 'العنوان',
              en: 'Address',
            ),
              style: _tableHeaderStyle(context),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _tr(
              context,
              'order_count',
              ar: 'عدد الطلبات',
              en: 'Order Count',
            ),
              style: _tableHeaderStyle(context),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _tr(
              context,
              'status',
              ar: 'الحالة',
              en: 'Status',
            ),
              style: _tableHeaderStyle(context),
            ),
          ),
          const SizedBox(width: 70),
        ],
      ),
    );
  }

  TextStyle _tableHeaderStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: context.colors.onSurfaceVariant,
        );
  }
}
