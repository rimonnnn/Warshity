import 'package:flutter/material.dart';
import 'package:warshity/core/theme/app_theme_extension.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get text => theme.textTheme;

   AppThemeExtension get appColors =>
      theme.extension<AppThemeExtension>()!;
}