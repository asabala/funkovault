// ------------------------------------------------------------
// Atlas Design System (ADS) 1.0
//
// Atlas Animation
//
// Standard animation durations and curves.
//
// Let's make something collectors don't just use...
// They remember.
// ------------------------------------------------------------

import 'package:flutter/animation.dart';

class AtlasAnimation {
  AtlasAnimation._();

  // ----------------------------------------------------------
  // Durations
  // ----------------------------------------------------------

  static const Duration instant =
  Duration(milliseconds: 100);

  static const Duration fast =
  Duration(milliseconds: 200);

  static const Duration standard =
  Duration(milliseconds: 300);

  static const Duration slow =
  Duration(milliseconds: 500);

  static const Duration cinematic =
  Duration(milliseconds: 800);

  static const Duration splash =
  Duration(milliseconds: 2000);

  // ----------------------------------------------------------
  // Curves
  // ----------------------------------------------------------

  static const Curve standardCurve =
      Curves.easeInOut;

  static const Curve entranceCurve =
      Curves.easeOutCubic;

  static const Curve exitCurve =
      Curves.easeInCubic;

  static const Curve emphasisCurve =
      Curves.easeOutBack;

  static const Curve gentleCurve =
      Curves.easeInOutSine;
}