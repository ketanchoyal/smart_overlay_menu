import 'package:flutter/material.dart';

/// Builds positioned overlay widgets with animations.
class OverlayWidgetBuilder {
  const OverlayWidgetBuilder._();

  /// Builds the top overlay widget with positioning and animation.
  static Widget buildTopWidget({
    required GlobalKey key,
    required Widget? widget,
    required EdgeInsets? padding,
    required Animation<double> animation,
    required Alignment? alignment,
    required Offset childOffset,
    required Size? childSize,
    required double repositionTop,
    required double repositionLeft,
  }) {
    if (widget == null || childSize == null) {
      return const SizedBox.shrink();
    }

    return _buildPositionedWidget(
      key: key,
      widget: widget,
      padding: padding,
      animation: animation,
      alignment: alignment ?? Alignment.centerLeft,
      childOffset: childOffset,
      childSize: childSize,
      repositionTop: repositionTop,
      repositionLeft: repositionLeft,
      isTopWidget: true,
    );
  }

  /// Builds the bottom overlay widget with positioning and animation.
  static Widget buildBottomWidget({
    required GlobalKey key,
    required Widget? widget,
    required EdgeInsets? padding,
    required Animation<double> animation,
    required Alignment? alignment,
    required Offset childOffset,
    required Size? childSize,
    required double repositionTop,
    required double repositionLeft,
  }) {
    if (widget == null || childSize == null) {
      return const SizedBox.shrink();
    }

    return _buildPositionedWidget(
      key: key,
      widget: widget,
      padding: padding,
      animation: animation,
      alignment: alignment ?? Alignment.centerLeft,
      childOffset: childOffset,
      childSize: childSize,
      repositionTop: repositionTop,
      repositionLeft: repositionLeft,
      isTopWidget: false,
    );
  }

  static Widget _buildPositionedWidget({
    required GlobalKey key,
    required Widget widget,
    required EdgeInsets? padding,
    required Animation<double> animation,
    required Alignment alignment,
    required Offset childOffset,
    required Size childSize,
    required double repositionTop,
    required double repositionLeft,
    required bool isTopWidget,
  }) {
    return AnimatedBuilder(
      key: key,
      animation: animation,
      builder: (context, child) {
        final position = _calculatePosition(
          alignment: alignment,
          childOffset: childOffset,
          childSize: childSize,
          repositionTop: repositionTop,
          repositionLeft: repositionLeft,
          isTopWidget: isTopWidget,
        );

        return Positioned(
          top: position.dy,
          left: position.dx,
          child: Transform.scale(
            scale: animation.value,
            child: Opacity(
              opacity: animation.value,
              child: _wrapWithPadding(widget, padding),
            ),
          ),
        );
      },
    );
  }

  static Offset _calculatePosition({
    required Alignment alignment,
    required Offset childOffset,
    required Size childSize,
    required double repositionTop,
    required double repositionLeft,
    required bool isTopWidget,
  }) {
    final baseX = childOffset.dx + repositionLeft;
    final baseY = isTopWidget 
        ? childOffset.dy + repositionTop
        : childOffset.dy + childSize.height + repositionTop;

    // Apply horizontal alignment
    double alignedX = baseX;
    if (alignment == Alignment.center) {
      alignedX = baseX + (childSize.width / 2);
    } else if (alignment == Alignment.centerRight) {
      alignedX = baseX + childSize.width;
    }

    return Offset(alignedX, baseY);
  }

  static Widget _wrapWithPadding(Widget widget, EdgeInsets? padding) {
    if (padding == null) return widget;
    return Padding(padding: padding, child: widget);
  }
}
