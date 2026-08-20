import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_card.dart';

class CustomerList extends StatelessWidget {
  const CustomerList({
    super.key,
    required this.customers,
    this.padding,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
    this.onTap,
    this.onDelete,
    this.padding1,
  });

  final List<CustomerModel> customers;

  final EdgeInsetsGeometry? padding;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final double? padding1;
  final void Function(int index)? onTap;
  final void Function(int index)? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: customers.length,
      separatorBuilder: (_, _) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final customer = customers[index];

        return CustomerCard(
          padding: padding1,
          name: customer.name!,
          phone: customer.phone.toString(),
          amount: customer.balance.toString(),
          hasDebt: customer.hasDebt!,
          // avatar: customer.avatar,
          onTap: () => onTap?.call(index),
          tapToDelete: () => onDelete?.call(index),
        );
      },
    );
  }
}
