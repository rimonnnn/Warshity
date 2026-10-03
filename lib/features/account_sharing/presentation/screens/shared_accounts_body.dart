import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/features/account_sharing/presentation/widgets/account_history_card_widget.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/connected_account_card_widget.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/empty_shared_accounts_widget.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/pending_invitation_card_widget.dart';

import 'shared_accounts_layout_widgets.dart';

class SharedAccountsBody extends StatelessWidget {
  const SharedAccountsBody({
    super.key,
    required this.isLoading,
    required this.items,
    required this.onRefresh,
    required this.onDelete,
  });

  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Future<void> Function() onRefresh;
  final void Function(String connectionId) onDelete;

  List<Map<String, dynamic>> _ofType(String type) {
    return items.where((item) => item['type'] == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const EmptySharedAccountsWidget();
    }

    final connected = _ofType('connected');
    final pending = _ofType('pending');
    final history = _ofType('history');

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 28,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (connected.isNotEmpty)
                      _buildSection(
                        title: 'connected_accounts'.tr(),
                        isMobile: isMobile,
                        children: connected.map((item) {
                          final id = item['connectionId']?.toString() ?? '';

                          return ConnectedAccountCardWidget(
                            email: item['email'].toString(),
                            onDelete: id.isEmpty ? null : () => onDelete(id),
                            isDeleting: false,
                          );
                        }).toList(),
                      ),

                    if (pending.isNotEmpty)
                      _buildSection(
                        title: 'pending_invitations'.tr(),
                        isMobile: isMobile,
                        children: pending.map((item) {
                          return PendingInvitationCardWidget(
                            email: item['email'].toString(),
                          );
                        }).toList(),
                      ),

                    if (history.isNotEmpty)
                      _buildSection(
                        title: 'invitation_history'.tr(),
                        isMobile: isMobile,
                        isLast: true,
                        children: history.map((item) {
                          return AccountHistoryCardWidget(
                            email: item['email'].toString(),
                            status: item['status'].toString(),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isMobile,
    required List<Widget> children,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: title),
        const SizedBox(height: 12),
        ResponsiveGrid(isMobile: isMobile, children: children),
        if (!isLast) const SizedBox(height: 28),
      ],
    );
  }
}
