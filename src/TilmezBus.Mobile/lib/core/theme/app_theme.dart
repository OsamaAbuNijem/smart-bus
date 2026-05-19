import 'package:flutter/material.dart';

/// Mirrors the SmartBus mobile template
/// (Template/login-en (3).html) and the web admin palette.
class AppColors {
  AppColors._();

  // Brand yellow.
  static const yellow = Color(0xFFF5C518);
  static const yellowDeep = Color(0xFFE0AE08);
  static const yellowSoft = Color(0xFFFFF8DC);
  static const yellowTint = Color(0xFFFFFBEB);

  // Ink (primary text).
  static const ink = Color(0xFF0F172A);
  static const inkSoft = Color(0xFF1E293B);

  // Slate neutrals.
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate50 = Color(0xFFF8FAFC);

  // Accents (badges, status).
  static const blue = Color(0xFF2563EB);
  static const blueSoft = Color(0xFFDBEAFE);
  static const emerald = Color(0xFF059669);
  static const emeraldSoft = Color(0xFFD1FAE5);
  static const violet = Color(0xFF7C3AED);
  static const violetSoft = Color(0xFFEDE9FE);

  // Legacy aliases — keep so the rest of the app keeps compiling while we
  // migrate. Map old names to new equivalents.
  static const yellowLight = yellowTint;
  static const yellowDark = yellowDeep;
  static const sidebarAccent = yellowSoft;
  static const blueLight = blueSoft;
  static const blueDark = Color(0xFF1E40AF);
  static const green = emerald;
  static const greenLight = emeraldSoft;
  static const greenDark = Color(0xFF15803D);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEF2F2);
  static const redDark = Color(0xFFB91C1C);
  static const orange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFFF7ED);
  static const purple = violet;
  static const purpleLight = violetSoft;
  static const bg = slate50;
  static const card = Color(0xFFFFFFFF);
  static const text = ink;
  static const text2 = slate500;
  static const text3 = slate400;
  static const border = slate200;
  static const border2 = slate300;
}

class AppShadows {
  AppShadows._();

  static const sm = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const md = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 6, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const lg = [
    BoxShadow(color: Color(0x140F172A), blurRadius: 25, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, 8)),
  ];

  static const yellow = [
    BoxShadow(color: Color(0x8CF5C518), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(_lightScheme);
  static ThemeData dark() => _build(_darkScheme);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.yellow,
    onPrimary: AppColors.ink,
    primaryContainer: AppColors.yellowTint,
    onPrimaryContainer: AppColors.yellowDeep,
    secondary: AppColors.blue,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.blueSoft,
    onSecondaryContainer: AppColors.blueDark,
    tertiary: AppColors.violet,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.violetSoft,
    onTertiaryContainer: AppColors.violet,
    error: AppColors.red,
    onError: Colors.white,
    errorContainer: AppColors.redLight,
    onErrorContainer: AppColors.redDark,
    surface: Colors.white,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.slate500,
    surfaceContainerHighest: AppColors.slate50,
    outline: AppColors.slate300,
    outlineVariant: AppColors.slate200,
    inversePrimary: AppColors.yellowDeep,
    inverseSurface: AppColors.ink,
    onInverseSurface: Colors.white,
    shadow: Color(0x140F172A),
    scrim: Color(0x66000000),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.yellow,
    onPrimary: AppColors.ink,
    primaryContainer: AppColors.yellowDeep,
    onPrimaryContainer: AppColors.yellowTint,
    secondary: Color(0xFF60A5FA),
    onSecondary: AppColors.ink,
    secondaryContainer: AppColors.blueDark,
    onSecondaryContainer: AppColors.blueSoft,
    tertiary: Color(0xFFA78BFA),
    onTertiary: AppColors.ink,
    tertiaryContainer: Color(0xFF5B21B6),
    onTertiaryContainer: AppColors.violetSoft,
    error: Color(0xFFF87171),
    onError: AppColors.ink,
    errorContainer: AppColors.redDark,
    onErrorContainer: AppColors.redLight,
    surface: Color(0xFF111827),
    onSurface: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFFCBD5E1),
    surfaceContainerHighest: Color(0xFF1F2937),
    outline: Color(0xFF4B5563),
    outlineVariant: Color(0xFF374151),
    inversePrimary: AppColors.yellowDeep,
    inverseSurface: Colors.white,
    onInverseSurface: AppColors.ink,
    shadow: Color(0x33000000),
    scrim: Color(0x99000000),
  );

  static ThemeData _build(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.slate50 : scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.slate50 : scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.yellowDeep, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.slate500),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.yellowDeep,
      ),
    );
  }
}
