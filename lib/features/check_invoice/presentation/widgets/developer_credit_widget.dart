import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class DeveloperCreditWidget extends StatelessWidget {
  const DeveloperCreditWidget({super.key});

  static const _phone = '01206174130';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'developed_by'.tr(),
            style: context.text.labelSmall?.copyWith(
              // ignore: deprecated_member_use
              color: context.colors.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "developer_names".tr(),
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              // ignore: deprecated_member_use
              color: context.colors.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            _phone,
            style: context.text.labelMedium?.copyWith(
              // ignore: deprecated_member_use
              color: context.colors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
