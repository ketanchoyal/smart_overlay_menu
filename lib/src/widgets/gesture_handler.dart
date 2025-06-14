import 'package:flutter/material.dart';
import 'package:smart_overlay_menu/src/models/overlay_config.dart';

/// Handles gesture interactions for the smart overlay.
class OverlayGestureHandler extends StatelessWidget {
  const OverlayGestureHandler({
    super.key,
    required this.child,
    required this.config,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onLongPressCancel,
  });

  final Widget child;
  final GestureConfig config;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final VoidCallback onLongPressCancel;

  @override
  Widget build(BuildContext context) {
    if (config.disabled) {
      return child;
    }

    return GestureDetector(
      onTap: _shouldHandleTap() ? _handleTap : null,
      onLongPressStart: _shouldHandleLongPress() ? (_) => onLongPressStart() : null,
      onLongPressEnd: _shouldHandleLongPress() ? (_) => onLongPressEnd() : null,
      onLongPressCancel: _shouldHandleLongPress() ? onLongPressCancel : null,
      child: child,
    );
  }

  bool _shouldHandleTap() => !config.disabled;

  bool _shouldHandleLongPress() => !config.disabled && !config.openWithTap;

  void _handleTap() {
    config.onPressed?.call();
    if (config.openWithTap) {
      onTap();
    }
  }
}
