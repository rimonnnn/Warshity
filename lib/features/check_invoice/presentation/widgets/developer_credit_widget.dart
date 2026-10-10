import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class DeveloperCreditWidget extends StatelessWidget {
  const DeveloperCreditWidget({super.key});

  static const _phone = '01206174130';
  static const _phone1 = '01279914491';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    // ألوان solid من الـ scheme بدل onSurface.withOpacity(...):
    // withOpacity deprecated، والشفافية بتختلف النتيجة بين الـ light والـ dark
    final phoneStyle = context.text.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'developed_by'.tr(),
            style: context.text.labelSmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 2),
          Text(
            "developer_names".tr(),
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // الرقمين جنب بعض بدل سطرين (الفاتورة أقصر)، وينزلوا سطرين لو العرض ضاق
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              // ltr: الأرقام ماتتعكسش في العربي
              Text(_phone, style: phoneStyle),
              Text(_phone1, style: phoneStyle),
            ],
          ),
        ],
      ),
    );
  }
}
