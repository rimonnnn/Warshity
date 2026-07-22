import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

void showAnimatedSnackDialog(
  BuildContext context, {

  required String? message,
  required AnimatedSnackBarType type,
}) {
  AnimatedSnackBar.material(
    message ?? "",
    type: type,
    mobileSnackBarPosition: MobileSnackBarPosition.bottom,
    desktopSnackBarPosition: DesktopSnackBarPosition.bottomCenter,
  ).show(context);
}
