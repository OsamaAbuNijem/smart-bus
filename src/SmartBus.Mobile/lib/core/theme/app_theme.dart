import 'package:flutter/material.dart';

/// Mirrors the SmartBus web palette (src/SmartBus.Web/wwwroot/css/admin/base.css).
class AppColors {
  AppColors._();

  // Primary brand — yellow.
  static const yellow = Color(0xFFFFD700);
  static const yellowLight = Color(0xFFFFFDE7);
  static const yellowDark = Color(0xFFB8960C);
  static const sidebarAccent = Color(0xFFFFE066);

  // Secondary accents.
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFEFF6FF);
  static const blueDark = Color(0xFF1E40AF);

  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFFF0FDF4);
  static const greenDark = Color(0xFF15803D);

  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEF2F2);
  static const redDark = Color(0xFFB91C1C);

  static const orange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFFF7ED);

  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFF5F3FF);

  // Neutrals.
  static const bg = Color(0xFFF9FAFB);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF111111);
  static const text2 = Color(0xFF475569);
  static const text3 = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const border2 = Color(0xFFD1D5DB);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(_lightScheme);
  static ThemeData dark() => _build(_darkScheme);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.yellow,
    onPrimary: AppColors.text,
    primaryContainer: AppColors.yellowLight,
    onPrimaryContainer: AppColors.yellowDark,
    secondary: AppColors.blue,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.blueLight,
    onSecondaryContainer: AppColors.blueDark,
    tertiary: AppColors.purple,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.purpleLight,
    onTertiaryContainer: AppColors.purple,
    error: AppColors.red,
    onError: Colors.white,
    errorContainer: AppColors.redLight,
    onErrorContainer: AppColors.redDark,
    surface: AppColors.card,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.text2,
    surfaceContainerHighest: AppColors.bg,
    outline: AppColors.border2,
    outlineVariant: AppColors.border,
    inversePrimary: AppColors.yellowDark,
    inverseSurface: AppColors.text,
    onInverseSurface: AppColors.card,
    shadow: Color(0x14000000),
    scrim: Color(0x66000000),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.yellow,
    onPrimary: AppColors.text,
    primaryContainer: AppColors.yellowDark,
    onPrimaryContainer: AppColors.yellowLight,
    secondary: Color(0xFF60A5FA),
    onSecondary: AppColors.text,
    secondaryContainer: AppColors.blueDark,
    onSecondaryContainer: AppColors.blueLight,
    tertiary: Color(0xFFA78BFA),
    onTertiary: AppColors.text,
    tertiaryContainer: Color(0xFF5B21B6),
    onTertiaryContainer: AppColors.purpleLight,
    error: Color(0xFFF87171),
    onError: AppColors.text,
    errorContainer: AppColors.redDark,
    onErrorContainer: AppColors.redLight,
    surface: Color(0xFF111827),
    onSurface: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFFCBD5E1),
    surfaceContainerHighest: Color(0xFF1F2937),
    outline: Color(0xFF4B5563),
    outlineVariant: Color(0xFF374151),
    inversePrimary: AppColors.yellowDark,
    inverseSurface: AppColors.card,
    onInverseSurface: AppColors.text,
    shadow: Color(0x33000000),
    scrim: Color(0x99000000),
  );

  static ThemeData _build(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.bg : scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }
}
