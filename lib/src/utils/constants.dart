import 'package:flutter/material.dart';
import 'package:smart_overlay_menu/src/widgets/figma_curve.dart';

/// Constants used throughout the smart overlay menu package.
class SmartOverlayConstants {
  SmartOverlayConstants._();

  /// Default animation durations
  static const Duration defaultPressFeedbackDuration = Duration(milliseconds: 200);
  static const Duration defaultPressFeedbackReverseDuration = Duration(milliseconds: 100);
  static const Duration defaultRepositionDuration = Duration(milliseconds: 300);
  static const Duration defaultTransitionDuration = Duration(milliseconds: 200);

  /// Default scale factors
  static const double defaultPressFeedbackScale = 0.95;

  /// Default padding values
  static const EdgeInsets defaultScreenPadding = EdgeInsets.zero;

  /// Default alignments
  static const Alignment defaultTopWidgetAlignment = Alignment.centerLeft;
  static const Alignment defaultBottomWidgetAlignment = Alignment.centerLeft;

  /// Animation curves
  static const Curve defaultPressCurve = Curves.easeInQuint;
  static Curve defaultPressReverseCurve = FigmaSpringCurve.quick;
  static const Curve defaultRepositionCurve = Curves.easeInOut;

  /// Route configuration
  static const bool defaultBarrierDismissible = true;
  static const bool defaultMaintainState = false;
  static const bool defaultFullscreenDialog = true;
  static const bool defaultOpaque = false;

  /// Default blur size
  static const double defaultBlurSize = 40;

  /// Default blur background color
  static Color defaultBlurBackgroundColor = Color(0xFFFFFFFF).withValues(alpha: 0.1);
}
