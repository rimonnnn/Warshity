import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/register/presentation/widgets/custom_drobdown.dart';
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
    final authCubit = context.read<AuthCubit>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: authCubit,
        child: EditStoreInfoDialog(
          initialShopName: initialShopName,
          initialActivity: initialActivity,
        ),
      ),
    );

    if (saved == true && context.mounted) {
      final isArabic = context.locale.languageCode == 'ar';
      showAnimatedSnackDialog(
        context,
        message: isArabic
            ? 'تم تحديث بيانات المتجر بنجاح'
            : 'Store information updated successfully',
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
  late final Stream<List<String>> _categoriesStream;

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
    _categoriesStream = context.read<AuthCubit>().categoriesStream;
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
        _errorMessage = context.locale.languageCode == 'ar'
            ? 'يجب تسجيل الدخول أولاً.'
            : 'You must be signed in to edit store information.';
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
        _errorMessage = context.locale.languageCode == 'ar'
            ? 'تعذر حفظ بيانات المتجر. تحقق من الاتصال وحاول مرة أخرى.'
            : 'Could not save store information. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final colors = context.colors;

    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Icon(Icons.storefront_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isArabic ? 'تعديل بيانات المتجر' : 'Edit store information',
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
                    return isArabic
                        ? 'اكتب اسم المتجر.'
                        : 'Enter the store name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<String>>(
                stream: _categoriesStream,
                builder: (context, snapshot) {
                  final activities = <String>{
                    ..._registeredActivities,
                    ...(snapshot.data ?? const <String>[]),
                  }.toList();

                  if (_selectedActivity != null &&
                      !activities.contains(_selectedActivity)) {
                    activities.insert(0, _selectedActivity!);
                  }

                  return CustomDropdown(
                    label: 'activity'.tr(),
                    hint: 'select_activity'.tr(),
                    items: activities,
                    width: 420,
                    height: 56,
                    selectedItem: _selectedActivity,
                    prefixIconData: Icons.business_outlined,
                    borderRadius: 12,
                    validator: (value) {
                      final activity = value ?? _selectedActivity;
                      if (activity == null || activity.trim().isEmpty) {
                        return 'select_activity'.tr();
                      }
                      return null;
                    },
                    onSelected: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedActivity = value;
                              _errorMessage = null;
                            });
                          },
                    onAddCategory: _isSaving
                        ? null
                        : (categoryName) async {
                            await context.read<AuthCubit>().addCategory(
                              categoryName,
                            );

                            if (!mounted) return;
                            setState(() {
                              _selectedActivity = categoryName;
                              _errorMessage = null;
                            });
                          },
                  );
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
          child: Text(isArabic ? 'إلغاء' : 'Cancel'),
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
          label: Text(isArabic ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }
}
