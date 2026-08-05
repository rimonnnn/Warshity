import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class LowStockItem extends StatelessWidget {
  final String productName;
  final String remainText;
  final String buttonText;
  final VoidCallback? onPressed;

  const LowStockItem({
    super.key,
    required this.productName,
    required this.remainText,
    this.buttonText = "طلب توريد",
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    remainText,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Spacer(),
              FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("order".tr()),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
