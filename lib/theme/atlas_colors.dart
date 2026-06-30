// ------------------------------------------------------------
// Atlas Design System (ADS) 1.0
//
// Atlas Color Language
//
// Every color has a purpose.
// Never use raw Color(...) values throughout the app.
//
// Let's make something collectors don't just use...
// They remember.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class AtlasColors {
  AtlasColors._();

  // ----------------------------------------------------------
  // Primary Brand Colors
  // ----------------------------------------------------------

  static const Color midnight = Color(0xFF08111D);

  static const Color intelligenceBlue = Color(0xFF1E88E5);

  static const Color vaultGold = Color(0xFFD4AF37);

  static const Color atlasSilver = Color(0xFFB8C1CC);

  // ----------------------------------------------------------
  // Status Colors
  // ----------------------------------------------------------

  static const Color success = Color(0xFF32D583);

  static const Color warning = Color(0xFFF5A524);

  static const Color danger = Color(0xFFE5484D);

  static const Color info = intelligenceBlue;

  // ----------------------------------------------------------
  // Backgrounds
  // ----------------------------------------------------------

  static const Color background = midnight;

  static const Color surface = Color(0xFF111B2B);

  static const Color card = Color(0xFF182233);

  // ----------------------------------------------------------
  // Text
  // ----------------------------------------------------------

  static const Color textPrimary = Colors.white;

  static const Color textSecondary = atlasSilver;

  static const Color textMuted = Color(0xFF7E8A9A);

  // ----------------------------------------------------------
  // Borders
  // ----------------------------------------------------------

  static const Color border = Color(0xFF293547);

  static const Color divider = Color(0xFF243041);

  // ----------------------------------------------------------
  // Effects
  // ----------------------------------------------------------

  static const Color glow = intelligenceBlue;

  static const Color shadow = Colors.black54;
}