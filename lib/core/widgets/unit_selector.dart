import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class UnitSelector extends StatelessWidget {
  const UnitSelector({
    super.key,
    required this.units,
    required this.selectedUnit,
    required this.enabled,
    required this.onChanged,
    this.isAddingUnit = false,
    this.onAddUnit,
  });

  final List<String> units;
  final String selectedUnit;
  final bool enabled;
  final bool isAddingUnit;
  final ValueChanged<String> onChanged;
  final VoidCallback? onAddUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final unitField = DropdownButtonFormField<String>(
      value: units.contains(selectedUnit) ? selectedUnit : null,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      onChanged: enabled
          ? (value) {
              if (value != null) onChanged(value);
            }
          : null,
      items: units
          .map(
            (unit) => DropdownMenuItem<String>(
              value: unit,
              child: Text(unit, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      decoration: InputDecoration(
        hintText: 'choose_unit'.tr(),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 16, 10, 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outlineVariant.withOpacity(.6)),
        ),
      ),
    );

    final addButton = OutlinedButton.icon(
      onPressed: enabled && !isAddingUnit ? onAddUnit : null,
      icon: isAddingUnit
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          : const Icon(Icons.add_rounded, size: 20),
      label: Text('add_unit'.tr()),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary),

        fixedSize: const Size(150, 48),
        minimumSize: const Size(150, 48),
        maximumSize: const Size(150, 48),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'unit_label'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  unitField,
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(width: 150, child: addButton),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: unitField),
                const SizedBox(width: 10),
                SizedBox(width: 150, child: addButton),
              ],
            );
          },
        ),
      ],
    );
  }
}
