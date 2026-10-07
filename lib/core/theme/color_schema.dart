import 'package:flutter/material.dart';

// Light colors ====>> //

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFF0F766E),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFCCFBF1),
  onPrimaryContainer: Color(0xFF134E4A),

  secondary: Color(0xFF14B8A6),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCCFBF1),
  onSecondaryContainer: Color(0xFF134E4A),

  tertiary: Color(0xFFF59E0B),
  onTertiary: Color(0xFF422006),
  tertiaryContainer: Color(0xFFFEF3C7),
  onTertiaryContainer: Color(0xFF78350F),

  error: Color(0xFFDC2626),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFEE2E2),
  onErrorContainer: Color(0xFF7F1D1D),

  surface: Color(0xFFF8FAFC),
  onSurface: Color(0xFF0F172A),

  surfaceContainerHighest: Color(0xFFE2E8F0),
  surfaceContainerHigh: Color(0xFFEFF2F5),
  surfaceContainer: Color(0xFFF1F5F9),
  surfaceContainerLow: Color(0xFFF8FAFC),
  surfaceContainerLowest: Color(0xFFFFFFFF),

  outline: Color(0xFF64748B),
  outlineVariant: Color(0xFFCBD5E1),

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),

  inverseSurface: Color(0xFF1E293B),
  onInverseSurface: Color(0xFFF1F5F9),
  inversePrimary: Color(0xFF5EEAD4),

  surfaceTint: Color(0xFF0F766E),
);

// Dark colors ====>> //

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFF1DD3C4),
  onPrimary: Color(0xFF04201F),
  primaryContainer: Color(0xFF0E4650),
  onPrimaryContainer: Color(0xFFCFFAF5),

  secondary: Color(0xFF6FE3D8),
  onSecondary: Color(0xFF04201F),
  secondaryContainer: Color(0xFF0E3A44),
  onSecondaryContainer: Color(0xFFBFF5EF),

  tertiary: Color(0xFFFFB020), // Amber (تنبيه المخزون / طلب توريد)
  onTertiary: Color(0xFF3A2500),
  tertiaryContainer: Color(0xFF5A3A00),
  onTertiaryContainer: Color(0xFFFFE2A8),

  error: Color(0xFFFF5A5F),
  onError: Color(0xFF3F0508),
  errorContainer: Color(0xFF4A1D2A),
  onErrorContainer: Color(0xFFFFD9DB),

  surface: Color(0xFF081426), // Background
  onSurface: Color(0xFFFFFFFF),
  onSurfaceVariant: Color(0xFFA5B4CA), // Text secondary (مكانه ناقص عندك)

  surfaceContainerLowest: Color(0xFF050E1B),
  surfaceContainerLow: Color(0xFF0B1A2F),
  surfaceContainer: Color(0xFF0F2038), // الكروت
  surfaceContainerHigh: Color(0xFF142A44),
  surfaceContainerHighest: Color(0xFF18304D),

  outline: Color(0xFF8EA2BF),
  outlineVariant: Color(0xFF1C3452), // Border

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),

  inverseSurface: Color(0xFFF1F5F9),
  onInverseSurface: Color(0xFF081426),
  inversePrimary: Color(0xFF0F766E),

  surfaceTint: Colors.transparent, // يمنع الـ tint فوق الكروت
);
