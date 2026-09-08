import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';

class QuantityBottomSheet extends StatefulWidget {
  const QuantityBottomSheet({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final int quantity;
  final Future<void> Function(int newQuantity) onQuantityChanged;

  static Future<void> show({
    required BuildContext context,
    required int quantity,
    required Future<void> Function(int newQuantity) onQuantityChanged,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return QuantityBottomSheet(
          quantity: quantity,
          onQuantityChanged: onQuantityChanged,
        );
      },
    );
  }

  @override
  State<QuantityBottomSheet> createState() => _QuantityBottomSheetState();
}

class _QuantityBottomSheetState extends State<QuantityBottomSheet> {
  final TextEditingController controller = TextEditingController();

  bool increase = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _confirmQuantity() async {
    final value = int.tryParse(
      controller.text.trim(),
    );

    if (value == null || value <= 0) {
      return;
    }

    if (!increase && value > widget.quantity) {
      showAnimatedSnackDialog(
        context,
        message: 'not_enough_quantity'.tr(),
        type: AnimatedSnackBarType.error,
      );
      return;
    }

    final newQuantity = increase
        ? widget.quantity + value
        : widget.quantity - value;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('confirm'.tr()),
          content: Text(
            increase
                ? '${'increase'.tr()} $value${'?'.tr()}'
                : '${'decrease'.tr()} $value?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text('confirm'.tr()),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    Navigator.pop(context);

    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await widget.onQuantityChanged(newQuantity);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      showAnimatedSnackDialog(
        context,
        message: increase
            ? 'quantity_increased_successfully'.tr()
            : 'quantity_decreased_successfully'.tr(),
        type: AnimatedSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      showAnimatedSnackDialog(
        context,
        message: e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        type: AnimatedSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'quantity'.tr(),
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text('increase'.tr()),
                      selected: increase,
                      onSelected: (_) {
                        setState(() {
                          increase = true;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('decrease'.tr()),
                      selected: !increase,
                      onSelected: (_) {
                        setState(() {
                          increase = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'enter_quantity'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmQuantity,
                  child: Text('confirm'.tr()),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}