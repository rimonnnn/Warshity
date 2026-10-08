import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/settings/presentation/widgets/settings_section.dart';

/// نفس شكل [SettingsSection] بعنوان افتراضي "store_information"
/// وزر تعديل اختياري في نهاية الـ header.
/// wrapper رفيع بدل نسخة مكررة من الـ styling.
class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({
    super.key,
    required this.children,
    this.title,
    this.onEdit,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  });

  final List<Widget> children;

  final String? title;
  final VoidCallback? onEdit;

  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: title ?? "store_information".tr(),
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
      // الزر بيظهر بس لو في onEdit، بدل زر رمادي معطّل
      trailing: onEdit == null
          ? null
          : IconButton(
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.edit_outlined, color: context.colors.primary),
            ),
      children: children,
    );
  }
}
