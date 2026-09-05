import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class FinallyPrice extends StatelessWidget {
  const FinallyPrice({
    super.key,
    required this.total,
  });

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 8,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 8,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFB6D088),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "net_invoice".tr(),
            style: context.text.bodyLarge!.copyWith(
              color: const Color(0xFF6F4627),
            ),
          ),
          Text(
            total.toStringAsFixed(2),
            style: context.text.bodyLarge!.copyWith(
              color: const Color(0xFF6F4627),
            ),
          ),
        ],
      ),
    );
  }
}