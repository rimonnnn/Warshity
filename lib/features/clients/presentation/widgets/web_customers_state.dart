part of '../layout/web_client.dart';

class _WebCustomersState extends State<WebCustomers> {
  final TextEditingController searchController = TextEditingController();

  int selectedCustomerIndex = 0;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openAddCustomer() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<AddClientCubit>(),
          child: const AddClientDialog(),
        );
      },
    );
  }

  void _openDeleteDialog(CustomerModel customer) {
    if (customer.id == null) return;

    showDialog<void>(
      context: context,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<RemoveClientCubit>(),
          child: RemoveClientDialog(
            clientId: customer.id!,
            clientName: customer.name ?? '',
          ),
        );
      },
    );
  }

  void _openDebtDialog(CustomerModel customer) {
    if (customer.id == null) return;

    showDialog<void>(
      context: context,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<DebtCubit>(),
          child: DecreaseDebtDialog(
            clientId: customer.id!,
            currentBalance: customer.balance ?? 0,
          ),
        );
      },
    );
  }

  void _selectCustomer(int index) {
    setState(() {
      selectedCustomerIndex = index;
    });
  }

  int _filterIndex(ClientFilter filter) {
    switch (filter) {
      case ClientFilter.all:
        return 0;
      case ClientFilter.hasDebt:
        return 1;
      case ClientFilter.noDebt:
        return 2;
    }
  }

  void _applyFilter(int index) {
    final ClientFilter filter = switch (index) {
      0 => ClientFilter.all,
      1 => ClientFilter.hasDebt,
      2 => ClientFilter.noDebt,
      _ => ClientFilter.all,
    };

    context.read<ClientsCubit>().filterClients(filter);

    setState(() {
      selectedCustomerIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Directionality(
        textDirection: context.locale.languageCode == 'ar'
            ? .rtl
            : .ltr,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double pagePadding = constraints.maxWidth >= 1500
                ? 28
                : constraints.maxWidth >= 1100
                    ? 20
                    : 14;

            return SingleChildScrollView(
              padding: EdgeInsets.all(pagePadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1420),
                  child: BlocBuilder<ClientsCubit, ClientsState>(
                    builder: (context, state) {
                      if (state is ClientsLoading) {
                        return SizedBox(
                          height: constraints.maxHeight,
                          child: Center(
                            child: LoadingWidget(
                              message: _tr(
                                context,
                                'loading_clients',
                                ar: 'جاري تحميل العملاء...',
                                en: 'Loading customers...',
                              ),
                            ),
                          ),
                        );
                      }

                      if (state is ClientsError) {
                        return _ErrorState(message: state.message);
                      }

                      if (state is! ClientsLoaded) {
                        return const SizedBox.shrink();
                      }

                      final List<CustomerModel> customers =
                          List<CustomerModel>.from(state.displayedClients);

                      if (customers.isNotEmpty &&
                          selectedCustomerIndex >= customers.length) {
                        selectedCustomerIndex = customers.length - 1;
                      }

                      final CustomerModel? selectedCustomer = customers.isEmpty
                          ? null
                          : customers[selectedCustomerIndex];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PageHeader(
                            count: customers.length,
                            onAdd: _openAddCustomer,
                          ),
                          const SizedBox(height: 16),
                          _StatsSection(customers: customers),
                          const SizedBox(height: 16),
                          _Toolbar(
                            controller: searchController,
                            filters: [
                              _tr(
                                context,
                                'all',
                                ar: 'الكل',
                                en: 'All',
                              ),
                              _tr(
                                context,
                                'debt',
                                ar: 'مديونية',
                                en: 'Debt',
                              ),
                              _tr(
                                context,
                                'balanced',
                                ar: 'حساب متزن',
                                en: 'Balanced',
                              ),
                            ],
                            selectedIndex: _filterIndex(state.filter),
                            onFilterSelected: _applyFilter,
                            onSearch: (query) {
                              context
                                  .read<ClientsCubit>()
                                  .searchClients(query);
                            },
                          ),
                          const SizedBox(height: 16),
                          _MainCustomersArea(
                            customers: customers,
                            selectedCustomer: selectedCustomer,
                            selectedCustomerIndex: selectedCustomerIndex,
                            onSelectCustomer: _selectCustomer,
                            onDeleteCustomer: _openDeleteDialog,
                            onPayDebt: _openDebtDialog,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
