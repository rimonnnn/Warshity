import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/features/home/data/recent_operation_model.dart';
import 'package:warshity/features/home/presentation/widgets/recent_operation_card.dart';

class RecentOperationList extends StatelessWidget {
  const RecentOperationList({
    super.key,
    required this.operations,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding,
    this.onItemTap, this.avatarSize, this.widthbetween, this.horzontalPadding, this.verticalPadding, this.borderRadius,
  });

  final List<RecentOperationModel> operations;

  final bool shrinkWrap;

  final ScrollPhysics physics;

  final EdgeInsetsGeometry? padding;

  final void Function(int index)? onItemTap;
  final double? avatarSize;
  final double? widthbetween;
final double? horzontalPadding;
final double? verticalPadding;
final double? borderRadius;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: operations.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = operations[index];

        return RecentOperationCard(
          customerName: item.customerName,
          time: item.time,
          price: item.price,
          avatar: item.avatar,
          avatarSize:avatarSize ,
          widthbetween: widthbetween,
          horzontalPadding: horzontalPadding,
          verticalPadding: verticalPadding,
          borderradius: borderRadius,
          onTap: () => onItemTap?.call(index),
        );
      },
    );
  }
}
