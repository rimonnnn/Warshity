import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';

class EditStoreInfoDialog extends StatefulWidget {
  const EditStoreInfoDialog({
    super.key,
    required this.initialShopName,
    required this.initialActivity,
  });

  final String initialShopName;
  final String initialActivity;

  static Future<void> show({
    required BuildContext context,
    required String initialShopName,
    required String initialActivity,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => EditStoreInfoDialog(
        initialShopName: initialShopName,
        initialActivity: initialActivity,
      ),
    );

    if (saved == true && context.mounted) {
      showAnimatedSnackDialog(
        context,
        message: 'updated'.tr(),
        type: AnimatedSnackBarType.success,
      );
    }
  }

  @override
  State<EditStoreInfoDialog> createState() => _EditStoreInfoDialogState();
}

class _EditStoreInfoDialogState extends State<EditStoreInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _shopNameController;
  late String? _selectedActivity;
  bool _isSaving = false;
  String? _errorMessage;

  List<String> get _registeredActivities => [
    'activities.carpentry'.tr(),
    'activities.plumbing'.tr(),
    'activities.electricity'.tr(),
    'activities.painting'.tr(),
    'activities.blacksmith'.tr(),
    'activities.ac'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.initialShopName);
    _selectedActivity = widget.initialActivity.trim().isEmpty
        ? null
        : widget.initialActivity;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() {
        _errorMessage = 'signed in'.tr();
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
            'shopName': _shopNameController.text.trim(),
            'activity': _selectedActivity!.trim(),
          });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Check your connection'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activities = _registeredActivities;
    final selected = _selectedActivity;

    if (selected != null && !activities.contains(selected)) {
      activities.insert(0, selected);
    }

    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Icon(Icons.storefront_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
            'Edit store information'.tr(),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _shopNameController,
                enabled: !_isSaving,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'store_name'.tr(),
                  prefixIcon: const Icon(Icons.store_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'enter_store_name'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selected,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'activity'.tr(),
                  prefixIcon: const Icon(Icons.business_outlined),
                  border: const OutlineInputBorder(),
                ),
                items: activities
                    .map(
                      (activity) => DropdownMenuItem<String>(
                        value: activity,
                        child: Text(
                          activity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _selectedActivity = value;
                          _errorMessage = null;
                        });
                      },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'select_activity'.tr();
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text('cancel'.tr()),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined, size: 18),
          label: Text('save'.tr()),
        ),
      ],
    );
  }
}
