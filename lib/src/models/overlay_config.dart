import 'package:flutter/material.dart';

/// Configuration data for overlay positioning and behavior.
class OverlayConfig {
  const OverlayConfig({
    required this.childOffset,
    required this.childSize,
    required this.repositionAnimationDuration,
    required this.screenPadding,
    this.topWidgetAlignment,
    this.bottomWidgetAlignment,
    this.blurSize,
    this.blurBackgroundColor,
  });

  final Offset childOffset;
  final Size? childSize;
  final Duration repositionAnimationDuration;
  final EdgeInsets screenPadding;
  final Alignment? topWidgetAlignment;
  final Alignment? bottomWidgetAlignment;
  final double? blurSize;
  final Color? blurBackgroundColor;
}

/// Configuration for press feedback animation.
class PressFeedbackConfig {
  const PressFeedbackConfig({
    required this.scale,
    required this.duration,
    required this.curve,
    this.reverseDuration,
    this.reverseCurve,
  });

  final double scale;
  final Duration duration;
  final Curve curve;
  final Duration? reverseDuration;
  final Curve? reverseCurve;
}

/// Configuration for gesture handling.
class GestureConfig {
  const GestureConfig({
    required this.openWithTap,
    required this.disabled,
    this.onPressed,
  });

  final bool openWithTap;
  final bool disabled;
  final VoidCallback? onPressed;
}
