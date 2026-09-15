import 'package:flutter/animation.dart';

/// Atlas Design System motion tokens.
///
/// Centralizes durations and curves so animations feel consistent
/// across cards, accordions, loaders, navigation, and future AI surfaces.
final class AtlasMotion {
  AtlasMotion._();

  // ----------------------------------------------------------
  // Durations
  // ----------------------------------------------------------

  static const Duration instant = Duration(milliseconds: 80);

  static const Duration fast = Duration(milliseconds: 140);

  static const Duration standard = Duration(milliseconds: 220);

  static const Duration emphasis = Duration(milliseconds: 320);

  static const Duration slow = Duration(milliseconds: 480);

  // ----------------------------------------------------------
  // Curves
  // ----------------------------------------------------------

  static const Curve enter = Curves.easeOutCubic;

  static const Curve exit = Curves.easeInCubic;

  static const Curve standardCurve = Curves.easeInOutCubic;

  static const Curve emphasized = Curves.easeOutBack;

  static const Curve linear = Curves.linear;

  // ----------------------------------------------------------
  // Semantic Motion
  // ----------------------------------------------------------

  static const Duration pressDuration = fast;

  static const Duration hoverDuration = standard;

  static const Duration expandDuration = standard;

  static const Duration progressDuration = emphasis;

  static const Duration pageTransitionDuration = emphasis;

  static const Duration searchDebounceDuration = Duration(milliseconds: 350);

  static const Curve pressCurve = enter;

  static const Curve expandCurve = enter;

  static const Curve progressCurve = enter;

  static const Curve pageTransitionCurve = standardCurve;
}
