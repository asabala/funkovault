// ------------------------------------------------------------
// Atlas Design System (ADS) 1.0
//
// Atlas Theme
//
// Global Flutter theme for Funko Vault powered by Atlas.
//
// Let's make something collectors don't just use...
// They remember.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import 'atlas_colors.dart';
import 'atlas_radius.dart';
import 'atlas_typography.dart';

class AtlasTheme {
  AtlasTheme._();

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AtlasColors.background,

      colorScheme: const ColorScheme.dark(
        primary: AtlasColors.intelligenceBlue,
        secondary: AtlasColors.vaultGold,
        surface: AtlasColors.surface,
        error: AtlasColors.danger,
        onPrimary: AtlasColors.textPrimary,
        onSecondary: AtlasColors.midnight,
        onSurface: AtlasColors.textPrimary,
        onError: AtlasColors.textPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AtlasColors.background,
        foregroundColor: AtlasColors.textPrimary,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: AtlasTypography.headingMedium,
      ),

      cardTheme: CardThemeData(
        color: AtlasColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AtlasRadius.lg),
          side: const BorderSide(color: AtlasColors.border),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AtlasColors.surface,
        labelStyle: AtlasTypography.label,
        hintStyle: const TextStyle(color: AtlasColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AtlasRadius.md),
          borderSide: const BorderSide(color: AtlasColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AtlasRadius.md),
          borderSide: const BorderSide(color: AtlasColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AtlasRadius.md),
          borderSide: const BorderSide(
            color: AtlasColors.intelligenceBlue,
            width: 2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AtlasColors.intelligenceBlue,
          foregroundColor: AtlasColors.textPrimary,
          textStyle: AtlasTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AtlasRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AtlasColors.intelligenceBlue,
          textStyle: AtlasTypography.label,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AtlasColors.surface,
        selectedColor: AtlasColors.intelligenceBlue,
        disabledColor: AtlasColors.border,
        labelStyle: AtlasTypography.bodySmall,
        secondaryLabelStyle: AtlasTypography.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AtlasRadius.pill),
          side: const BorderSide(color: AtlasColors.border),
        ),
      ),

      dividerTheme: const DividerThemeData(color: AtlasColors.divider),

      listTileTheme: const ListTileThemeData(
        iconColor: AtlasColors.atlasSilver,
        textColor: AtlasColors.textPrimary,
        subtitleTextStyle: AtlasTypography.bodySmall,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AtlasColors.vaultGold,
        foregroundColor: AtlasColors.midnight,
      ),

      textTheme: const TextTheme(
        displayLarge: AtlasTypography.displayLarge,
        displayMedium: AtlasTypography.displayMedium,
        headlineLarge: AtlasTypography.headingLarge,
        headlineMedium: AtlasTypography.headingMedium,
        headlineSmall: AtlasTypography.headingSmall,
        bodyLarge: AtlasTypography.bodyLarge,
        bodyMedium: AtlasTypography.bodyMedium,
        bodySmall: AtlasTypography.bodySmall,
        labelLarge: AtlasTypography.label,
      ),
    );
  }
}
