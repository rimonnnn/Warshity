import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Small, reusable dialog that collects a custom unit name.
/// Persistence is handled by AddProductDialog through AddProductCubit.
class AddUnitDialog extends StatefulWidget {
  const AddUnitDialog({
    super.key,
    required this.existingUnits,
  });

  final List<String> existingUnits;

  static Future<String?> show(
    BuildContext context, {
    required List<String> existingUnits,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddUnitDialog(existingUnits: existingUnits),
    );
  }

  @override
  State<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends State<AddUnitDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() => _errorText = 'unit_name_required'.tr());
      return;
    }

    if (name.length > 40) {
      setState(() => _errorText = 'unit_name_too_long'.tr());
      return;
    }

    final normalizedName = name.toLowerCase();
    final alreadyExists = widget.existingUnits.any(
      (unit) => unit.trim().toLowerCase() == normalizedName,
    );

    if (alreadyExists) {
      setState(() => _errorText = 'unit_already_exists'.tr());
      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: Text('add_unit_dialog_title'.tr()),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLength: 40,
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.start,
          onChanged: (_) {
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'unit_name'.tr(),
            hintText: 'unit_name_hint'.tr(),
            border: const OutlineInputBorder(),
            counterText: '',
            errorText: _errorText,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr()),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add_rounded),
          label: Text('add'.tr()),
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
        ),
      ],
    );
  }
}
