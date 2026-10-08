import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_info_line.dart';

class CustomerProfileCard extends StatelessWidget {
  const CustomerProfileCard({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = (customer.name ?? '').trim().isEmpty
        ? '—'
        : customer.name!.trim();
    final phone = (customer.phone ?? '').trim();
    final address = (customer.address ?? '').trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .7)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: colors.primary,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                if (phone.isNotEmpty)
                  CustomerInfoLine(icon: Icons.phone_outlined, text: phone),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  CustomerInfoLine(
                    icon: Icons.location_on_outlined,
                    text: address,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.badge_outlined, color: colors.primary, size: 24),
          ),
        ],
      ),
    );
  }
}
