// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class PageViewWidget extends StatelessWidget {
  final double width;
  final double height;
  final String imageUrl;
  final String title;
  final String describtion;
  const PageViewWidget({
    super.key,
    required this.width,
    required this.height,
    required this.imageUrl,
    required this.title,
    required this.describtion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainer,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Flexible(child: Image.asset(imageUrl, fit: BoxFit.cover)),
        ),

        HeightSpace(30),
        Text(title, style: context.text.bodyLarge, textAlign: TextAlign.center),
        HeightSpace(12),
        Text(
          describtion,
          style: context.text.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
