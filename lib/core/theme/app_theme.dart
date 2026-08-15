import 'package:flutter/material.dart';
import 'package:warshity/core/theme/app_theme_extension.dart';
import 'package:warshity/core/theme/color_schema.dart';

import 'app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        colorScheme: lightColorScheme,

        textTheme: AppTextTheme.lightTextTheme,

        scaffoldBackgroundColor: lightColorScheme.surface,

        canvasColor: lightColorScheme.surface,

        dividerColor: lightColorScheme.outlineVariant,

        appBarTheme: _lightAppBarTheme,

        elevatedButtonTheme: _elevatedButtonTheme(lightColorScheme),

        outlinedButtonTheme: _outlinedButtonTheme(lightColorScheme),

        inputDecorationTheme: _lightInputDecoration,

        cardTheme: _lightCardTheme,

        dialogTheme: _lightDialogTheme,

        snackBarTheme: _lightSnackBarTheme,

        checkboxTheme: _checkboxTheme(lightColorScheme),

        switchTheme: _switchTheme(lightColorScheme),

        extensions: const [
          AppThemeExtension(
            success: Color(0xFF16A34A),
            warning: Color(0xFFF59E0B),
            info: Color(0xFF0EA5E9),
          ),
        ],
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: darkColorScheme,

        textTheme: AppTextTheme.darkTextTheme,

        scaffoldBackgroundColor: darkColorScheme.surface,

        canvasColor: darkColorScheme.surface,

        dividerColor: darkColorScheme.outlineVariant,

        appBarTheme: _darkAppBarTheme,

        elevatedButtonTheme: _elevatedButtonTheme(darkColorScheme),

        outlinedButtonTheme: _outlinedButtonTheme(darkColorScheme),

        inputDecorationTheme: _darkInputDecoration,

        cardTheme: _darkCardTheme,

        dialogTheme: _darkDialogTheme,

        snackBarTheme: _darkSnackBarTheme,

        checkboxTheme: _checkboxTheme(darkColorScheme),

        switchTheme: _switchTheme(darkColorScheme),

        extensions: const [
          AppThemeExtension(
            success: Color(0xFF22C55E),
            warning: Color(0xFFFBBF24),
            info: Color(0xFF38BDF8),
          ),
        ],
      );

  // ---------------- APP BAR ----------------

  static const _lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFF0F172A),
    surfaceTintColor: Colors.transparent,
  );

  static const _darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFFF1F5F9),
    surfaceTintColor: Colors.transparent,
  );

  // ---------------- CARD ----------------

  static const _lightCardTheme = CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(12),
      ),
    ),
  );

  static const _darkCardTheme = CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: Color(0xFF1E293B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(12),
      ),
    ),
  );

  // ---------------- INPUT ----------------

  static final _lightInputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: lightColorScheme.surfaceContainerLowest,

    border: _border(lightColorScheme.outlineVariant),

    enabledBorder: _border(lightColorScheme.outlineVariant),

    focusedBorder: _border(
      lightColorScheme.primary,
      width: 2,
    ),

    errorBorder: _border(
      lightColorScheme.error,
    ),

    focusedErrorBorder: _border(
      lightColorScheme.error,
      width: 2,
    ),
  );

  static final _darkInputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: darkColorScheme.surfaceContainer,

    border: _border(darkColorScheme.outlineVariant),

    enabledBorder: _border(darkColorScheme.outlineVariant),

    focusedBorder: _border(
      darkColorScheme.primary,
      width: 2,
    ),

    errorBorder: _border(
      darkColorScheme.error,
    ),

    focusedErrorBorder: _border(
      darkColorScheme.error,
      width: 2,
    ),
  );

  // ---------------- BUTTON ----------------

  static ElevatedButtonThemeData _elevatedButtonTheme(
    ColorScheme scheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,

        backgroundColor: scheme.primary,

        foregroundColor: scheme.onPrimary,

        minimumSize: const Size(
          double.infinity,
          52,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(
    ColorScheme scheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,

        side: BorderSide(
          color: scheme.primary,
        ),

        minimumSize: const Size(
          double.infinity,
          52,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ---------------- CHECKBOX ----------------

  static CheckboxThemeData _checkboxTheme(
    ColorScheme scheme,
  ) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }

          return Colors.transparent;
        },
      ),
    );
  }

  // ---------------- SWITCH ----------------

  static SwitchThemeData _switchTheme(
    ColorScheme scheme,
  ) {
    return SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(
        scheme.primary,
      ),
    );
  }

  // ---------------- DIALOG ----------------

  static const _lightDialogTheme = DialogThemeData(
    backgroundColor: Color(0xFFFFFFFF),
  );

  static const _darkDialogTheme = DialogThemeData(
    backgroundColor: Color(0xFF1E293B),
  );

  // ---------------- SNACKBAR ----------------

  static const _lightSnackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
  );

  static const _darkSnackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
  );

  // ---------------- BORDER ----------------

  static OutlineInputBorder _border(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}