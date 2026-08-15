import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/core/widgets/customer_balance_type.dart';
import 'package:warshity/core/widgets/customer_notes_field.dart';
import 'package:warshity/features/AddClient/presentation/widgets/save_customer_button.dart';

class AddCustomerWeb extends StatefulWidget {
  const AddCustomerWeb({super.key});

  @override
  State<AddCustomerWeb> createState() => _AddCustomerWebState();
}

class _AddCustomerWebState extends State<AddCustomerWeb> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final balanceController = TextEditingController();
  final notesController = TextEditingController();

  bool hasDebt = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "add_customer".tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                HeightSpace(32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: nameController,
                            label: "customer_name1".tr(),
                            hint: "customer_name_hint".tr(),
                            width: double.infinity,
                          ),

                          HeightSpace(20),

                          CustomTextField(
                            controller: phoneController,
                            label: "phone_number".tr(),
                            hint: "phone_hint".tr(),
                            keyboardType: TextInputType.phone,
                            width: double.infinity,
                          ),

                          HeightSpace(20),

                          CustomTextField(
                            controller: addressController,
                            label: "address".tr(),
                            hint: "address_hint".tr(),
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),

                    WidthSpace(32),

                    Expanded(
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: balanceController,
                            label: "opening_balance".tr(),
                            hint: "0.00",
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            width: double.infinity,
                          ),

                          HeightSpace(20),

                          CustomerBalanceType(
                            value: hasDebt,
                            onChanged: (value) {
                              setState(() {
                                hasDebt = value;
                              });
                            },
                          ),

                          HeightSpace(20),

                          CustomerNotesField(
                            controller: notesController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                HeightSpace(40),

                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 220,
                    child: SaveCustomerButton(
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}