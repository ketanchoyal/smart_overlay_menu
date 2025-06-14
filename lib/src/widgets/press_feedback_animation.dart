import 'package:flutter/material.dart';
import 'package:smart_overlay_menu/src/models/overlay_config.dart';

/// Manages press feedback animation for overlay interactions.
class PressFeedbackAnimationController {
  PressFeedbackAnimationController({
    required TickerProvider vsync,
    required this.config,
  }) : _controller = AnimationController(
          duration: config.duration,
          reverseDuration: config.reverseDuration,
          vsync: vsync,
        ) {
    _animation = Tween<double>(
      begin: 1.0,
      end: config.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: config.curve,
    ));
  }

  final PressFeedbackConfig config;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _isScalingDown = false;
  bool _shouldOpenMenu = false;

  /// Gets the animation for building animated widgets.
  Animation<double> get animation => _animation;

  /// Gets the animation controller.
  AnimationController get controller => _controller;

  /// Whether the animation is currently scaling down.
  bool get isScalingDown => _isScalingDown;

  /// Whether the menu should open after animation.
  bool get shouldOpenMenu => _shouldOpenMenu;

  /// Adds a status listener to the animation controller.
  void addStatusListener(AnimationStatusListener listener) {
    _controller.addStatusListener(listener);
  }

  /// Performs a quick press animation (tap).
  Future<void> performQuickPress() async {
    await _controller.forward();
    await _controller.reverse();
  }

  /// Starts the long press animation.
  Future<void> startLongPress() async {
    _isScalingDown = true;
    _shouldOpenMenu = true;
    await _controller.forward();
  }

  /// Cancels the long press animation.
  Future<void> cancelLongPress() async {
    _shouldOpenMenu = false;
    _isScalingDown = false;
    if (_controller.value != 0.0) {
      await _controller.reverse();
    }
  }

  /// Completes the long press and reverses animation.
  Future<void> completeLongPress() async {
    _isScalingDown = false;
  }

  /// Sets whether the menu should open.
  void setShouldOpenMenu(bool shouldOpen) {
    _shouldOpenMenu = shouldOpen;
  }

  /// Disposes of the animation controller.
  void dispose() {
    _controller.dispose();
  }
}

/// Widget that applies press feedback animation to its child.
class PressFeedbackAnimationWidget extends StatelessWidget {
  const PressFeedbackAnimationWidget({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Transform.scale(
        scale: animation.value,
        child: child,
      ),
    );
  }
}
