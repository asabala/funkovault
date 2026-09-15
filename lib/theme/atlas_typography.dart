// ------------------------------------------------------------
// Atlas Design System (ADS) 1.0
//
// Atlas Typography
//
// Every font style used throughout Atlas.
//
// Let's make something collectors don't just use...
// They remember.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import 'atlas_colors.dart';

class AtlasTypography {
  AtlasTypography._();

  // ----------------------------------------------------------
  // Display
  // ----------------------------------------------------------

  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AtlasColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AtlasColors.textPrimary,
  );

  // ----------------------------------------------------------
  // Headings
  // ----------------------------------------------------------

  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AtlasColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AtlasColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AtlasColors.textPrimary,
  );

  // ----------------------------------------------------------
  // Body
  // ----------------------------------------------------------

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AtlasColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AtlasColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AtlasColors.textSecondary,
  );

  // ----------------------------------------------------------
  // Labels
  // ----------------------------------------------------------

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AtlasColors.textSecondary,
  );

  // ----------------------------------------------------------
  // Metrics
  // ----------------------------------------------------------

  static const TextStyle metricLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AtlasColors.intelligenceBlue,
  );

  static const TextStyle metricMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AtlasColors.textPrimary,
  );

  static const TextStyle metricSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AtlasColors.textPrimary,
  );

  // ----------------------------------------------------------
  // Status
  // ----------------------------------------------------------

  static const TextStyle success = TextStyle(
    color: AtlasColors.success,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle warning = TextStyle(
    color: AtlasColors.warning,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle danger = TextStyle(
    color: AtlasColors.danger,
    fontWeight: FontWeight.bold,
  );
}
