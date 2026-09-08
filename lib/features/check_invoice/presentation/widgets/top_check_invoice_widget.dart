import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';

class TopCheckInvoiceWidget extends StatelessWidget {
  const TopCheckInvoiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Masiter",
              style: context.text.headlineSmall!.copyWith(
                color: context.colors.primary,
              ),
            ),
            SizedBox(width: 12),
            ClipOval(child: Image.asset(AppAssets.logo, width: 80, height: 80)),
          ],
        ),
      ],
    );
  }
}
