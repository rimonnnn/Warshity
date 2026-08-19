import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class TextWidget extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;

  const TextWidget({
    super.key,
    required this.textKey,
    this.style,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      textKey,
      textAlign: textAlign,
      style: (style ?? context.text.headlineLarge)?.copyWith(
        color: color ?? context.colors.primary,
      ),
    );
  }
}
