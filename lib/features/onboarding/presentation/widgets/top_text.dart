import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class TopText extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  const TopText({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: onTap,
        child: Text(text, style: context.text.bodyLarge),
      ),
    );
  }
}
