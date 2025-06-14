import 'package:flutter/material.dart';
import 'package:smart_overlay_menu/src/utils/positioning_calculator.dart';

/// Manages dimensions and positioning calculations for overlay widgets.
class OverlayDimensionManager {
  const OverlayDimensionManager({
    required this.topWidgetKey,
    required this.bottomWidgetKey,
    required this.childOffset,
    required this.childSize,
    required this.screenPadding,
    required this.topWidgetPadding,
    required this.bottomWidgetPadding,
  });

  final GlobalKey topWidgetKey;
  final GlobalKey bottomWidgetKey;
  final Offset childOffset;
  final Size? childSize;
  final EdgeInsets screenPadding;
  final EdgeInsets? topWidgetPadding;
  final EdgeInsets? bottomWidgetPadding;

  /// Gets dimensions for both top and bottom widgets.
  ({WidgetDimensions top, WidgetDimensions bottom}) getWidgetDimensions() {
    final topDimensions = PositioningCalculator.getWidgetDimensions(
      topWidgetKey,
      topWidgetPadding,
    );
    
    final bottomDimensions = PositioningCalculator.getWidgetDimensions(
      bottomWidgetKey,
      bottomWidgetPadding,
    );
    
    return (top: topDimensions, bottom: bottomDimensions);
  }

  /// Checks if all required dimensions are available.
  bool areDimensionsReady(WidgetDimensions top, WidgetDimensions bottom) {
    // We need to check dimensions for widgets that have contexts (are in the widget tree)
    // but return invalid dimensions (haven't been laid out yet)
    
    final topContext = topWidgetKey.currentContext;
    final bottomContext = bottomWidgetKey.currentContext;
    
    // If a widget has a context but invalid dimensions, it's not ready yet
    if (topContext != null && !top.isValid) {
      return false;
    }
    
    if (bottomContext != null && !bottom.isValid) {
      return false;
    }
    
    // If we get here, either the widgets don't exist or they have valid dimensions
    return true;
  }

  /// Calculates repositioning data for the overlay.
  RepositionData calculateRepositioning(BuildContext context) {
    final dimensions = getWidgetDimensions();
    
    if (!areDimensionsReady(dimensions.top, dimensions.bottom)) {
      return RepositionData.none;
    }

    return PositioningCalculator.calculateReposition(
      screenSize: MediaQuery.of(context).size,
      safeArea: MediaQuery.of(context).padding,
      childOffset: childOffset,
      childSize: childSize,
      screenPadding: screenPadding,
      topWidget: dimensions.top,
      bottomWidget: dimensions.bottom,
    );
  }
}
