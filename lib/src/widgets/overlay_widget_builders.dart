import 'package:flutter/material.dart';
import 'package:smart_overlay_menu/src/widgets/figma_curve.dart';

/// Constants for overlay widget animations.
class OverlayAnimationConstants {
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 150);
  static const EdgeInsets defaultTopPadding = EdgeInsets.only(bottom: 8.0);
  static const EdgeInsets defaultBottomPadding = EdgeInsets.only(top: 8.0);
}

/// Builds overlay widgets with proper positioning and animations.
class OverlayWidgetBuilders {
  const OverlayWidgetBuilders._();

  /// Builds the top overlay widget with positioning and animation.
  static Widget buildTopWidget({
    required GlobalKey widgetKey,
    required Widget widget,
    required EdgeInsets? padding,
    required Alignment? alignment,
    required Size? childSize,
    required double leftPosition,
    required double topPosition,
    required Animation<double> repositionAnimation,
    required Animation<double> fadeAnimation,
    required bool isClosing,
    required Curve? animationCurve,
  }) {
    return _buildPositionedWidget(
      widgetKey: widgetKey,
      widget: widget,
      padding: padding ?? OverlayAnimationConstants.defaultTopPadding,
      alignment: alignment,
      childSize: childSize,
      leftPosition: leftPosition,
      topPosition: topPosition,
      repositionAnimation: repositionAnimation,
      fadeAnimation: fadeAnimation,
      isClosing: isClosing,
      animationCurve: animationCurve,
      scaleAlignment: Alignment.bottomCenter,
    );
  }

  /// Builds the bottom overlay widget with positioning and animation.
  static Widget buildBottomWidget({
    required GlobalKey widgetKey,
    required Widget widget,
    required EdgeInsets? padding,
    required Alignment? alignment,
    required Size? childSize,
    required double leftPosition,
    required double topPosition,
    required Animation<double> repositionAnimation,
    required Animation<double> fadeAnimation,
    required bool isClosing,
    required Curve? animationCurve,
  }) {
    return _buildPositionedWidget(
      widgetKey: widgetKey,
      widget: widget,
      padding: padding ?? OverlayAnimationConstants.defaultBottomPadding,
      alignment: alignment,
      childSize: childSize,
      leftPosition: leftPosition,
      topPosition: topPosition,
      repositionAnimation: repositionAnimation,
      fadeAnimation: fadeAnimation,
      isClosing: isClosing,
      animationCurve: animationCurve,
      scaleAlignment: Alignment.topCenter,
    );
  }

  static Widget _buildPositionedWidget({
    required GlobalKey widgetKey,
    required Widget widget,
    required EdgeInsets padding,
    required Alignment? alignment,
    required Size? childSize,
    required double leftPosition,
    required double topPosition,
    required Animation<double> repositionAnimation,
    required Animation<double> fadeAnimation,
    required bool isClosing,
    required Curve? animationCurve,
    required Alignment scaleAlignment,
  }) {
    Widget wrappedWidget = Container(
      key: widgetKey,
      padding: padding,
      child: widget,
    );

    // Apply alignment translation if needed
    final translateX = _calculateTranslateX(alignment, childSize);
    if (translateX != 0.0) {
      wrappedWidget = FractionalTranslation(
        translation: Offset(translateX, 0),
        child: wrappedWidget,
      );
    }

    return Positioned(
      top: topPosition,
      left: leftPosition,
      child: AnimatedBuilder(
        animation: isClosing ? fadeAnimation : repositionAnimation,
        builder: (context, child) {
          if (isClosing) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: child,
            );
          } else {
            return TweenAnimationBuilder<double>(
              duration: OverlayAnimationConstants.defaultAnimationDuration,
              curve: animationCurve ?? FigmaSpringCurve.bouncy,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  alignment: scaleAlignment,
                  child: child,
                );
              },
              child: child,
            );
          }
        },
        child: wrappedWidget,
      ),
    );
  }

  static double _calculateTranslateX(Alignment? alignment, Size? childSize) {
    if (alignment == null || childSize == null) return 0.0;

    if (_isRightAlignment(alignment)) {
      return -1.0;
    } else if (_isCenterAlignment(alignment)) {
      return -0.5;
    }
    return 0.0; // Left alignment (default)
  }

  static bool _isRightAlignment(Alignment alignment) {
    return alignment == Alignment.centerRight ||
        alignment == Alignment.topRight ||
        alignment == Alignment.bottomRight;
  }

  static bool _isCenterAlignment(Alignment alignment) {
    return alignment == Alignment.center ||
        alignment == Alignment.topCenter ||
        alignment == Alignment.bottomCenter;
  }
}

/// Calculates positioning for overlay widgets.
class OverlayPositionCalculator {
  const OverlayPositionCalculator._();

  /// Calculates the left position based on alignment.
  static double calculateLeftPosition({
    required double currentChildX,
    required Size? childSize,
    required Alignment? alignment,
  }) {
    if (alignment == null || childSize == null) {
      return currentChildX;
    }

    if (OverlayWidgetBuilders._isRightAlignment(alignment)) {
      return currentChildX + childSize.width;
    } else if (OverlayWidgetBuilders._isCenterAlignment(alignment)) {
      return currentChildX + (childSize.width / 2);
    }
    
    return currentChildX; // Left alignment (default)
  }

  /// Calculates top widget position.
  static double calculateTopWidgetPosition({
    required double currentChildY,
    required double topWidgetHeight,
    required double screenTop,
    required double childHeight,
    required double availableHeight,
  }) {
    if (childHeight > availableHeight && currentChildY <= screenTop + topWidgetHeight) {
      return screenTop; // Special case: child larger than screen
    }
    return currentChildY - topWidgetHeight; // Normal case
  }

  /// Calculates bottom widget position.
  static double calculateBottomWidgetPosition({
    required double currentChildY,
    required double childHeight,
    required double bottomWidgetHeight,
    required double screenBottom,
    required double availableHeight,
  }) {
    if (childHeight > availableHeight) {
      return screenBottom - bottomWidgetHeight; // Special case: child larger than screen
    }
    return currentChildY + childHeight; // Normal case
  }
}
