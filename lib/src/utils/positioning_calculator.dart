import 'package:flutter/material.dart';

/// Data class for widget dimensions.
class WidgetDimensions {
  const WidgetDimensions({
    required this.height,
    required this.width,
    required this.isValid,
  });

  final double height;
  final double width;
  final bool isValid;

  static const WidgetDimensions invalid = WidgetDimensions(
    height: 0.0,
    width: 0.0,
    isValid: false,
  );
}

/// Data class for repositioning calculations.
class RepositionData {
  const RepositionData({
    required this.topOffset,
    required this.leftOffset,
    required this.shouldReposition,
  });

  final double topOffset;
  final double leftOffset;
  final bool shouldReposition;

  static const RepositionData none = RepositionData(
    topOffset: 0.0,
    leftOffset: 0.0,
    shouldReposition: false,
  );
}

/// Utility class for calculating overlay positioning.
class PositioningCalculator {
  const PositioningCalculator._();

  /// Gets dimensions of a widget using its render box.
  static WidgetDimensions getWidgetDimensions(
    GlobalKey key,
    EdgeInsets? padding,
  ) {
    final context = key.currentContext;
    if (context == null) return WidgetDimensions.invalid;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return WidgetDimensions.invalid;
    }

    final size = renderBox.size;
    return WidgetDimensions(
      height: size.height + (padding?.vertical ?? 0),
      width: size.width + (padding?.horizontal ?? 0),
      isValid: true,
    );
  }

  /// Calculates repositioning based on screen constraints.
  static RepositionData calculateReposition({
    required Size screenSize,
    required EdgeInsets safeArea,
    required Offset childOffset,
    required Size? childSize,
    required EdgeInsets screenPadding,
    required WidgetDimensions topWidget,
    required WidgetDimensions bottomWidget,
  }) {
    if (childSize == null) return RepositionData.none;

    // Calculate screen boundaries correctly
    final screenTop = safeArea.top + screenPadding.top;
    final screenBottom = screenSize.height - safeArea.bottom - screenPadding.bottom;
    final screenLeft = safeArea.left + screenPadding.left;
    final screenRight = screenSize.width - safeArea.right - screenPadding.right;

    // Calculate overflow conditions
    final topOverflow = _calculateTopOverflow(
      childOffset: childOffset,
      topWidgetHeight: topWidget.height,
      screenTop: screenTop,
    );

    final bottomOverflow = _calculateBottomOverflow(
      childOffset: childOffset,
      childHeight: childSize.height,
      bottomWidgetHeight: bottomWidget.height,
      screenBottom: screenBottom,
    );

    final leftOverflow = _calculateLeftOverflow(
      childOffset: childOffset,
      topWidgetWidth: topWidget.width,
      bottomWidgetWidth: bottomWidget.width,
      screenLeft: screenLeft,
    );

    final rightOverflow = _calculateRightOverflow(
      childOffset: childOffset,
      childWidth: childSize.width,
      topWidgetWidth: topWidget.width,
      bottomWidgetWidth: bottomWidget.width,
      screenRight: screenRight,
    );

    // Calculate adjustments
    double topAdjustment = 0.0;
    double leftAdjustment = 0.0;

    // Special case: if child is taller than screen, position it at the top
    final availableHeight = screenBottom - screenTop;
    if (childSize.height > availableHeight) {
      topAdjustment = screenTop - childOffset.dy;
    } else if (topOverflow > 0) {
      topAdjustment = topOverflow;
    } else if (bottomOverflow > 0) {
      topAdjustment = -bottomOverflow;
    }

    if (leftOverflow > 0) {
      leftAdjustment = leftOverflow;
    } else if (rightOverflow > 0) {
      leftAdjustment = -rightOverflow;
    }

    final shouldReposition = topAdjustment != 0.0 || leftAdjustment != 0.0;

    return RepositionData(
      topOffset: topAdjustment,
      leftOffset: leftAdjustment,
      shouldReposition: shouldReposition,
    );
  }

  static double _calculateTopOverflow({
    required Offset childOffset,
    required double topWidgetHeight,
    required double screenTop,
  }) {
    final topWidgetTop = childOffset.dy - topWidgetHeight;
    final overflow = screenTop - topWidgetTop;
    return overflow > 0 ? overflow : 0;
  }

  static double _calculateBottomOverflow({
    required Offset childOffset,
    required double childHeight,
    required double bottomWidgetHeight,
    required double screenBottom,
  }) {
    final bottomWidgetBottom = childOffset.dy + childHeight + bottomWidgetHeight;
    final overflow = bottomWidgetBottom - screenBottom;
    
    // Only return overflow if it's actually overflowing
    return overflow > 0 ? overflow : 0;
  }

  static double _calculateLeftOverflow({
    required Offset childOffset,
    required double topWidgetWidth,
    required double bottomWidgetWidth,
    required double screenLeft,
  }) {
    // Calculate potential left position of widgets when left-aligned with child
    final widgetLeftPosition = childOffset.dx;
    final overflow = screenLeft - widgetLeftPosition;
    
    return overflow > 0 ? overflow : 0;
  }

  static double _calculateRightOverflow({
    required Offset childOffset,
    required double childWidth,
    required double topWidgetWidth,
    required double bottomWidgetWidth,
    required double screenRight,
  }) {
    final maxWidgetWidth = topWidgetWidth > bottomWidgetWidth ? topWidgetWidth : bottomWidgetWidth;
    
    // Calculate potential right position of the widest widget when left-aligned with child
    final widgetRightPosition = childOffset.dx + maxWidgetWidth;
    final overflow = widgetRightPosition - screenRight;
    
    return overflow > 0 ? overflow : 0;
  }
}
