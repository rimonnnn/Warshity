import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key, required this.text1, required this.text2, this.onPress});
  final String text1;
  final String text2;
  final VoidCallback? onPress;
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text1.tr(),
        style: context.text.bodyLarge,
        children: [
          TextSpan(
            text: text2.tr(),
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = onPress,
          ),
        ],
      ),
    );
  }
}
