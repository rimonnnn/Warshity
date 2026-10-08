import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/features/settings/presentation/widgets/settings_section.dart';

/// نفس شكل [SettingsSection] بالظبط، بس العنوان الافتراضي "security".
/// بقى wrapper رفيع بدل نسخة مكررة من الـ styling، فأي تعديل في الشكل
/// بيتعمل في مكان واحد.
class SecurityCard extends StatelessWidget {
  const SecurityCard({
    super.key,
    required this.children,
    this.title,
    this.backgroundColor,
    this.borderRadius,
  });

  final List<Widget> children;

  final String? title;
  final Color? backgroundColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: title ?? "security".tr(),
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      children: children,
    );
  }
}
