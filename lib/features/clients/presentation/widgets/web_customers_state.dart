part of '../layout/web_client.dart';

class _WebCustomersState extends State<WebCustomers> {
  final TextEditingController searchController = TextEditingController();
  late final Stream<List<InvoiceModel>> _invoicesStream;

  int selectedCustomerIndex = 0;

  @override
  void initState() {
    super.initState();
    try {
      _invoicesStream = getIt<InvoicesRepository>().watchInvoices();
    } catch (_) {
      // No signed-in user yet (reload/cleared session): show as a stream
      // error instead of crashing initState.
      _invoicesStream = Stream.error(const UnauthenticatedException());
    }
  }

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

  Future<void> _reconcileLegacyInvoiceData() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('invoice_data_sync_title'.tr()),
        content: Text('invoice_data_sync_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('cancel'.tr()),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.sync_rounded),
            label: Text('sync_now'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final updatedRecords = await getIt<ClientsRepository>()
          .reconcileInvoiceOutstandingAmountsWithClientBalances();
      if (!mounted) return;

      final String message = updatedRecords == 0
          ? 'invoice_data_already_synced'.tr()
          : 'invoice_data_sync_success'.tr(
              args: [updatedRecords.toString()],
            );
      showAnimatedSnackDialog(
        context,
        message: message,
        type: AnimatedSnackBarType.success,
      );
    } catch (_) {
      if (!mounted) return;
      showAnimatedSnackDialog(
        context,
        message: 'invoice_data_sync_error'.tr(),
        type: AnimatedSnackBarType.error,
      );
    }
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
        textDirection: context.locale.languageCode == 'ar' ? .rtl : .ltr,
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
                              message: 'loading_clients'.tr(),
                            ),
                          ),
                        );
                      }

                      if (state is ClientsError) {
                        return _ErrorState(
                          message: state.message,
                          onRetry: () =>
                              context.read<ClientsCubit>().watchClients(),
                        );
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

                      return StreamBuilder<List<InvoiceModel>>(
                        stream: _invoicesStream,
                        builder: (context, invoiceSnapshot) {
                          final invoices =
                              invoiceSnapshot.data ?? const <InvoiceModel>[];
                          final invoiceCountsByClient = <String, int>{};
                          final totalPurchasesByClient = <String, double>{};

                          for (final customer in customers) {
                            final id = customer.id;
                            if (id != null && id.isNotEmpty) {
                              invoiceCountsByClient[id] = 0;
                              totalPurchasesByClient[id] = 0;
                            }
                          }

                          for (final invoice in invoices) {
                            final id = invoice.customerId;
                            if (invoiceCountsByClient.containsKey(id)) {
                              invoiceCountsByClient[id] =
                                  invoiceCountsByClient[id]! + 1;
                              totalPurchasesByClient[id] =
                                  (totalPurchasesByClient[id] ?? 0) +
                                  invoice.total;
                            }
                          }

                          final int? unpaidInvoicesCount =
                              invoiceSnapshot.hasData
                              ? invoices
                                    .where(
                                      (invoice) => invoice.remainingAmount > 0,
                                    )
                                    .length
                              : null;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PageHeader(
                                count: customers.length,
                                onAdd: _openAddCustomer,
                              ),
                              const SizedBox(height: 16),
                              _StatsSection(
                                customers: customers,
                                unpaidInvoicesCount: unpaidInvoicesCount,
                                invoicesLoading:
                                    !invoiceSnapshot.hasData &&
                                    !invoiceSnapshot.hasError,
                                invoicesError: invoiceSnapshot.hasError,
                                onReconcileInvoices:
                                    _reconcileLegacyInvoiceData,
                              ),
                              const SizedBox(height: 16),
                              _Toolbar(
                                controller: searchController,
                                filters: [
                                  'all'.tr(),
                                  'debt'.tr(),
                                  'balanced'.tr(),
                                ],
                                selectedIndex: _filterIndex(state.filter),
                                onFilterSelected: _applyFilter,
                                onSearch: (query) {
                                  context.read<ClientsCubit>().searchClients(
                                    query,
                                  );
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
                                invoiceCountsByClient: invoiceCountsByClient,
                                totalPurchasesByClient: totalPurchasesByClient,
                                invoiceCountsLoaded: invoiceSnapshot.hasData,
                                invoiceCountsError: invoiceSnapshot.hasError,
                              ),
                            ],
                          );
                        },
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
