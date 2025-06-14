import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_overlay_menu/src/models/overlay_config.dart';
import 'package:smart_overlay_menu/src/utils/constants.dart';
import 'package:smart_overlay_menu/src/widgets/gesture_handler.dart';
import 'package:smart_overlay_menu/src/widgets/press_feedback_animation.dart';
import 'package:smart_overlay_menu/src/widgets/smart_overlay_details.dart';

/// A controller for [SmartOverlayMenu] that allows programmatic control over the overlay.
class SmartOverlayMenuController {
  _SmartOverlayMenuState? _widgetState;
  bool _isOpened = false;

  void _addState(_SmartOverlayMenuState widgetState) {
    _widgetState = widgetState;
  }

  /// Opens the overlay menu programmatically.
  void open() {
    if (_widgetState != null) {
      _widgetState!.openOverlay(_widgetState!.context);
      _isOpened = true;
    }
  }

  /// Closes the overlay menu programmatically.
  void close() {
    if (_isOpened && _widgetState != null) {
      Navigator.of(_widgetState!.context, rootNavigator: true).pop();
      _isOpened = false;
      // Reset animation after closing
      _widgetState!._resetAnimation();
    }
  }

  /// Returns whether the overlay is currently open.
  bool get isOpened => _isOpened;
}

/// A widget that displays customizable overlay menus on long press or tap.
///
/// This widget provides a flexible way to show contextual menus and overlays
/// with automatic positioning, smooth animations, and haptic feedback.
///
/// Example usage:
/// ```dart
/// SmartOverlayHolder(
///   topWidget: Container(
///     padding: EdgeInsets.all(16),
///     color: Colors.blue,
///     child: Text('Edit'),
///   ),
///   bottomWidget: Container(
///     padding: EdgeInsets.all(16),
///     color: Colors.red,
///     child: Text('Delete'),
///   ),
///   child: Card(
///     child: Padding(
///       padding: EdgeInsets.all(16),
///       child: Text('Long press me!'),
///     ),
///   ),
/// )
/// ```
class SmartOverlayMenu extends StatefulWidget {
  /// The main widget that will trigger the overlay when interacted with.
  final Widget child;

  /// Optional widget to display above the child widget.
  final Widget? topWidget;

  /// Optional widget to display below the child widget.
  final Widget? bottomWidget;

  /// Padding around the top widget.
  final EdgeInsets? topWidgetPadding;

  /// Padding around the bottom widget.
  final EdgeInsets? bottomWidgetPadding;

  /// Callback function called when the child is pressed.
  final VoidCallback? onPressed;

  /// Duration of the overlay transition animation.
  final Duration? duration;

  /// Intensity of the background blur effect.
  final double? blurSize;

  /// Color of the blurred background.
  final Color? blurBackgroundColor;

  /// Whether to open the overlay on tap instead of long press.
  final bool openWithTap;

  /// Controller for programmatic control of the overlay.
  final SmartOverlayMenuController? controller;

  /// Callback function called when the overlay is opened.
  final VoidCallback? onOpened;

  /// Callback function called when the overlay is closed.
  final VoidCallback? onClosed;

  /// Duration of the repositioning animation.
  final Duration? repositionAnimationDuration;

  /// Curve of the repositioning animation.
  final Curve? repositionAnimationCurve;

  /// Padding from screen edges for positioning calculations.
  final EdgeInsets? screenPadding;

  /// Haptic feedback function to call when opening the overlay.
  final VoidCallback? haptic;

  /// Whether the overlay interaction is disabled.
  final bool disabled;

  /// Horizontal alignment of the top widget relative to the child.
  final Alignment? topWidgetAlignment;

  /// Horizontal alignment of the bottom widget relative to the child.
  final Alignment? bottomWidgetAlignment;

  /// Duration of the press feedback animation.
  final Duration? pressFeedbackDuration;

  /// Duration of the press feedback reverse animation.
  final Duration? pressFeedbackReverseDuration;

  /// Scale factor for the press feedback animation.
  final double? pressFeedbackScale;

  /// Curve for the press feedback reverse animation.
  final Curve? pressFeedbackReverseCurve;

  /// When true, if the child widget is larger than the available screen space
  /// (considering top and bottom widgets), it will be scaled down to fit.
  /// This allows for better positioning as if there was enough space.
  /// Defaults to false to maintain backward compatibility.
  final bool scaleDownWhenTooLarge;

  /// Creates a [SmartOverlayMenu].
  ///
  /// The [child] parameter is required and represents the main widget that
  /// will trigger the overlay when long pressed or tapped.
  const SmartOverlayMenu({
    super.key,
    required this.child,
    this.topWidget,
    this.bottomWidget,
    this.topWidgetPadding,
    this.bottomWidgetPadding,
    this.onPressed,
    this.duration,
    this.blurSize = SmartOverlayConstants.defaultBlurSize,
    this.blurBackgroundColor,
    this.openWithTap = false,
    this.controller,
    this.onOpened,
    this.onClosed,
    this.repositionAnimationDuration,
    this.repositionAnimationCurve,
    this.screenPadding,
    this.haptic = HapticFeedback.lightImpact,
    this.disabled = false,
    this.topWidgetAlignment,
    this.bottomWidgetAlignment,
    this.pressFeedbackDuration,
    this.pressFeedbackReverseDuration,
    this.pressFeedbackScale,
    this.pressFeedbackReverseCurve,
    this.scaleDownWhenTooLarge = false,
  });

  /// Creates configuration objects from widget parameters.
  PressFeedbackConfig get _pressFeedbackConfig => PressFeedbackConfig(
        scale: pressFeedbackScale ?? SmartOverlayConstants.defaultPressFeedbackScale,
        duration: pressFeedbackDuration ?? SmartOverlayConstants.defaultPressFeedbackDuration,
        curve: SmartOverlayConstants.defaultPressCurve,
        reverseDuration: pressFeedbackReverseDuration ?? SmartOverlayConstants.defaultPressFeedbackReverseDuration,
        reverseCurve: pressFeedbackReverseCurve ?? SmartOverlayConstants.defaultPressReverseCurve,
      );

  /// Creates gesture configuration from widget parameters.
  GestureConfig get _gestureConfig => GestureConfig(
        openWithTap: openWithTap,
        disabled: disabled,
        onPressed: onPressed,
      );

  @override
  _SmartOverlayMenuState createState() => _SmartOverlayMenuState(controller);
}

class _SmartOverlayMenuState extends State<SmartOverlayMenu> with TickerProviderStateMixin {
  final GlobalKey _containerKey = GlobalKey();
  late final SmartOverlayMenuController _controller;
  late final PressFeedbackAnimationController _animationController;

  Offset _childOffset = Offset.zero;
  Size? _childSize;

  _SmartOverlayMenuState(SmartOverlayMenuController? controller) {
    _controller = controller ?? SmartOverlayMenuController();
    _controller._addState(this);
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
  }

  void _resetAnimation() {
    // Reset animation controller to initial state
    _animationController.controller.reset();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimationController() {
    _animationController = PressFeedbackAnimationController(
      vsync: this,
      config: widget._pressFeedbackConfig,
    );

    _animationController.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        _animationController.isScalingDown &&
        _animationController.shouldOpenMenu) {
      _completeAnimationAndOpenMenu();
    }
  }

  void _getOffset() {
    final renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    setState(() {
      _childOffset = offset;
      _childSize = size;
    });
  }

  Future<void> _completeAnimationAndOpenMenu() async {
    // Start overlay immediately without waiting for completeLongPress
    _controller.open();
    // Complete the animation in parallel (no reverse here, it happens in overlay)
    _animationController.completeLongPress();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      child: OverlayGestureHandler(
        config: widget._gestureConfig,
        onTap: _handleTapGesture,
        onLongPressStart: _handleLongPressStart,
        onLongPressEnd: _handleLongPressEnd,
        onLongPressCancel: _handleLongPressCancel,
        child: PressFeedbackAnimationWidget(
          animation: _animationController.animation,
          child: widget.child,
        ),
      ),
    );
  }

  Future<void> _handleTapGesture() async {
    await _animationController.performQuickPress();
    _controller.open();
  }

  Future<void> _handleLongPressStart() async {
    if (!widget.openWithTap) {
      await _animationController.startLongPress();
    }
  }

  Future<void> _handleLongPressEnd() async {
    if (!widget.openWithTap && _animationController.isScalingDown) {
      _animationController.setShouldOpenMenu(false);
      await _animationController.cancelLongPress();
    }
  }

  Future<void> _handleLongPressCancel() async {
    await _animationController.cancelLongPress();
  }

  Future<void> openOverlay(BuildContext context) async {
    _getOffset();
    _triggerHapticFeedback();
    widget.onOpened?.call();

    await _navigateToOverlay(context);
  }

  void _triggerHapticFeedback() {
    widget.haptic?.call();
  }

  Future<void> _navigateToOverlay(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true)
        .push(_createOverlayRoute())
        .whenComplete(() {
          widget.onClosed?.call();
          _resetAnimation();
        });
  }

  PageRouteBuilder _createOverlayRoute() {
    return PageRouteBuilder(
      transitionDuration: widget.duration ?? SmartOverlayConstants.defaultTransitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => _buildOverlayPage(animation),
      fullscreenDialog: SmartOverlayConstants.defaultFullscreenDialog,
      opaque: SmartOverlayConstants.defaultOpaque,
      barrierDismissible: SmartOverlayConstants.defaultBarrierDismissible,
      barrierColor: Colors.transparent,
      maintainState: SmartOverlayConstants.defaultMaintainState,
    );
  }

  Widget _buildOverlayPage(Animation<double> animation) {
    return SmartOverlayDetails(
      child: widget.child,
      childOffset: _childOffset,
      childSize: _childSize,
      topWidget: widget.topWidget,
      bottomWidget: widget.bottomWidget,
      topWidgetPadding: widget.topWidgetPadding,
      bottomWidgetPadding: widget.bottomWidgetPadding,
      blurSize: widget.blurSize,
      blurBackgroundColor: widget.blurBackgroundColor ?? SmartOverlayConstants.defaultBlurBackgroundColor,
      repositionAnimationDuration:
          widget.repositionAnimationDuration ?? SmartOverlayConstants.defaultRepositionDuration,
      screenPadding: widget.screenPadding ?? SmartOverlayConstants.defaultScreenPadding,
      topWidgetAlignment: widget.topWidgetAlignment,
      bottomWidgetAlignment: widget.bottomWidgetAlignment,
      scaleDownWhenTooLarge: widget.scaleDownWhenTooLarge,
      repositionAnimationCurve: widget.repositionAnimationCurve ?? SmartOverlayConstants.defaultRepositionCurve,
      pageAnimation: animation,
      pressFeedbackController: _animationController.controller,
      pressFeedbackAnimation: _animationController.animation,
      pressFeedbackReverseDuration: widget._pressFeedbackConfig.reverseDuration,
      pressFeedbackReverseCurve: widget._pressFeedbackConfig.reverseCurve,
    );
  }
}
