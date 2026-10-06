import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/customer_search_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/customer_search_state.dart';

import 'web_form_widgets.dart';
import 'web_misc_widgets.dart';

class WebCustomerSection extends StatelessWidget {
  const WebCustomerSection({super.key, required this.onAddClient});

  final VoidCallback onAddClient;

  @override
  Widget build(BuildContext context) {
    final searchCubit = context.read<CustomerSearchCubit>();

    return WebSectionCard(
      title: 'customer'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: WebSearchField(
                  hint: 'search_clients'.tr(),
                  onChanged: searchCubit.searchClients,
                  icon: Icons.search,
                ),
              ),
              const SizedBox(width: 12),
              WebActionButton(
                icon: Icons.person_add,
                label: 'add_client'.tr(),
                onTap: onAddClient,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _CustomerSearchResults(),
          const SizedBox(height: 12),
          const _SelectedCustomer(),
        ],
      ),
    );
  }
}

class _CustomerSearchResults extends StatelessWidget {
  const _CustomerSearchResults();

  @override
  Widget build(BuildContext context) {
    final searchCubit = context.read<CustomerSearchCubit>();
    final invoiceCubit = context.read<InvoiceCubit>();

    return BlocBuilder<CustomerSearchCubit, CustomerSearchState>(
      builder: (context, state) {
        if (state is CustomerSearchLoading) {
          return const WebSearchStatus(child: CircularProgressIndicator());
        }

        if (state is CustomerSearchError) {
          return WebSearchStatus(child: Text(state.message));
        }

        if (state is! CustomerSearchSuccess) {
          return const SizedBox.shrink();
        }

        if (state.clients.isEmpty) {
          return WebSearchStatus(child: Text('no_clients_found'.tr()));
        }

        return WebSearchResultCard(
          children: state.clients.map<Widget>((client) {
            return ListTile(
              dense: true,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(client.name ?? ''),
              subtitle: client.phone?.isNotEmpty == true
                  ? Text(client.phone!)
                  : null,
              onTap: () {
                if (client.id == null || client.name == null) return;

                invoiceCubit.selectCustomer(
                  customerId: client.id!,
                  customerName: client.name!,
                );

                searchCubit.clearSearch();
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _SelectedCustomer extends StatelessWidget {
  const _SelectedCustomer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (_, state) {
        final name = state.selectedCustomerName;

        if (name == null || name.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: context.colors.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<InvoiceCubit>().removeCustomer();
                  context.read<CustomerSearchCubit>().clearSearch();
                },
                tooltip: 'cancel'.tr(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        );
      },
    );
  }
}
