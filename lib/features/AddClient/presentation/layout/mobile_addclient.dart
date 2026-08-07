import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/AddClient/presentation/widgets/customer_balance_type.dart';
import 'package:warshity/features/AddClient/presentation/widgets/customer_notes_field.dart';
import 'package:warshity/features/AddClient/presentation/widgets/save_customer_button.dart';

class MobileAddclient extends StatefulWidget {
  const MobileAddclient({super.key});

  @override
  State<MobileAddclient> createState() => _AddCustomerMobileState();
}

class _AddCustomerMobileState extends State<MobileAddclient> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final balanceController = TextEditingController();
  final notesController = TextEditingController();

  bool hasDebt = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("add_customer".tr())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              CustomTextField(
                controller: nameController,
                label: "customer_name".tr(),
                hint: "customer_name_hint".tr(),
                width: double.infinity,
              ),

              HeightSpace(16.h),

              CustomTextField(
                controller: phoneController,
                label: "phone_number".tr(),
                hint: "phone_hint".tr(),
                keyboardType: TextInputType.phone,
                width: double.infinity,
              ),

              HeightSpace(16.h),

              CustomTextField(
                controller: addressController,
                label: "address".tr(),
                hint: "address_hint".tr(),
                width: double.infinity,
              ),

              HeightSpace(16.h),

              CustomTextField(
                controller: balanceController,
                label: "opening_balance".tr(),
                hint: "0.00",
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                width: double.infinity,
              ),

              HeightSpace(16.h),

              CustomerBalanceType(
                value: hasDebt,
                onChanged: (value) {
                  setState(() {
                    hasDebt = value;
                  });
                },
              ),

              HeightSpace(16.h),

              CustomerNotesField(controller: notesController),

              HeightSpace(32.h),

              SaveCustomerButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
