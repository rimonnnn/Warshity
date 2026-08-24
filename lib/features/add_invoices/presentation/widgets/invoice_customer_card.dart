import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/Cleints/presentation/cubit/clients_cubit.dart';

class InvoiceCustomerCard extends StatefulWidget {
  final VoidCallback onTap;
  final TextEditingController controller;
  final CustomerModel? selectedClient;
  final ValueChanged<CustomerModel>? onClientSelected;
  final VoidCallback? onClearClient;

  const InvoiceCustomerCard({
    super.key,
    required this.onTap,
    required this.controller,
    this.selectedClient,
    this.onClientSelected,
    this.onClearClient,
  });

  @override
  State<InvoiceCustomerCard> createState() => _InvoiceCustomerCardState();
}

class _InvoiceCustomerCardState extends State<InvoiceCustomerCard> {
  final FocusNode _focusNode = FocusNode();
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _showResults = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _selectClient(CustomerModel client) {
    widget.controller.clear();
    context.read<ClientsCubit>().searchClients('');
    _focusNode.unfocus();
    setState(() => _showResults = false);
    widget.onClientSelected?.call(client);
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.symmetric(horizontal: AppPadding.sm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.sm,
        vertical: AppPadding.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.selectedClient != null)
            _SelectedClientChip(
              client: widget.selectedClient!,
              onClear: widget.onClearClient,
            )
          else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: CustomTextField(
                hint: 'search_clients'.tr(),
                prefixIcon: AppAssets.searchIcon,
                focusNode: _focusNode,
                onChanged: (query) {
                  debugPrint('⌨️ TYPED: $query');

                  context.read<ClientsCubit>().searchClients(query);
                },

                controller: widget.controller,
                borderRadius: AppRadius.md,
                height: 48,
              ),
            ),
            if (_showResults)
              BlocBuilder<ClientsCubit, ClientsState>(
                builder: (context, state) {
                  if (state is! ClientsLoaded) return const SizedBox.shrink();
                  if (state.searchQuery.trim().isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final results = state.displayedClients;

                  if (results.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'no_clients_found'.tr(),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: results.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: context.colors.outlineVariant,
                      ),
                      itemBuilder: (context, index) {
                        final client = results[index];
                        return ListTile(
                          dense: true,
                          title: Text(client.name ?? ''),
                          subtitle: Text(client.phone ?? ''),
                          onTap: () => _selectClient(client),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
          HeightSpace(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'customer'.tr(),
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: widget.onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 16,
                        color: context.colors.onPrimaryContainer,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'add_client'.tr(),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onPrimaryContainer,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SelectedClientChip extends StatelessWidget {
  final CustomerModel client;
  final VoidCallback? onClear;

  const _SelectedClientChip({required this.client, this.onClear});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Row(
      children: [
        Icon(Icons.person, color: context.colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name ?? '',
                style: context.text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (client.phone != null)
                Text(
                  client.phone!,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (onClear != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClear,
            visualDensity: VisualDensity.compact,
          ),
      ],
    ),
  );
}
