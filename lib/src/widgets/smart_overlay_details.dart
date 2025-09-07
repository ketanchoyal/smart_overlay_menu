import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_overlay_menu/src/utils/positioning_calculator.dart';
import 'package:smart_overlay_menu/src/widgets/figma_curve.dart';
import 'package:smart_overlay_menu/src/widgets/overlay_dimension_manager.dart';
import 'package:smart_overlay_menu/src/widgets/overlay_widget_builders.dart';
import 'package:smart_overlay_menu/src/widgets/press_feedback_animation.dart';

class SmartOverlayDetails extends StatefulWidget {
  final Offset childOffset;
  final Size? childSize;
  final Widget child;
  final Widget? topWidget;
  final Widget? bottomWidget;
  final EdgeInsets? topWidgetPadding;
  final EdgeInsets? bottomWidgetPadding;
  final double? blurSize;
  final Color? blurBackgroundColor;
  final Duration repositionAnimationDuration;
  final EdgeInsets screenPadding;
  final Curve? repositionAnimationCurve;
  final Curve? topWidgetAnimationCurve;
  final Curve? bottomWidgetAnimationCurve;
  final Alignment? topWidgetAlignment;
  final Alignment? bottomWidgetAlignment;
  final bool scaleDownWhenTooLarge;
  final Animation<double>? pageAnimation;
  final AnimationController? pressFeedbackController;
  final Animation<double>? pressFeedbackAnimation;
  final Duration? pressFeedbackReverseDuration;
  final Curve? pressFeedbackReverseCurve;

  const SmartOverlayDetails({
    Key? key,
    required this.child,
    required this.childOffset,
    required this.childSize,
    this.topWidget,
    this.bottomWidget,
    this.topWidgetPadding,
    this.bottomWidgetPadding,
    this.blurSize,
    this.blurBackgroundColor,
    required this.repositionAnimationDuration,
    required this.screenPadding,
    this.repositionAnimationCurve,
    this.topWidgetAnimationCurve,
    this.bottomWidgetAnimationCurve,
    this.topWidgetAlignment,
    this.bottomWidgetAlignment,
    this.scaleDownWhenTooLarge = false,
    this.pageAnimation,
    this.pressFeedbackController,
    this.pressFeedbackAnimation,
    this.pressFeedbackReverseDuration,
    this.pressFeedbackReverseCurve,
  }) : super(key: key);

  @override
  _SmartOverlayDetailsState createState() => _SmartOverlayDetailsState();
}

class _SmartOverlayDetailsState extends State<SmartOverlayDetails> with TickerProviderStateMixin {
  late AnimationController _repositionController;
  late Animation<double> _repositionAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  final GlobalKey _topWidgetKey = GlobalKey();
  final GlobalKey _bottomWidgetKey = GlobalKey();

  double _adjustedChildY = 0.0;
  double _adjustedChildX = 0.0;
  bool _needsRepositioning = false;
  bool _isClosing = false;
  Timer? _repositioningTimer;
  int _repositioningRetryCount = 0;
  double _scaleFactor = 1.0;
  Size? _scaledChildSize;

  // Animation state for scaling
  bool _needsScaling = false;
  Size? _originalChildSize;
  Size? _targetChildSize;

  @override
  void initState() {
    super.initState();
    _adjustedChildY = widget.childOffset.dy;
    _adjustedChildX = widget.childOffset.dx;

    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _repositionController = AnimationController(duration: widget.repositionAnimationDuration, vsync: this);
    _repositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _repositionController, curve: widget.repositionAnimationCurve ?? FigmaSpringCurve.slow),
    );

    // Fade controller for top/bottom widgets during closing
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 150), // Quick fade
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Blur controller for blur effect animation
    _blurController = AnimationController(
      duration: widget.repositionAnimationDuration,
      vsync: this,
    );
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _blurController, curve: Curves.linear)); //.repositionAnimationCurve ?? FigmaSpringCurve.slow));

    // Calculate positioning after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateRepositioning();
    });

    // Only start blur animation if no page animation is provided
    if (widget.pageAnimation == null) {
      Future.delayed(Duration(milliseconds: 16), () {
        if (mounted) {
          _blurController.forward();
        }
      });
    }

    // Always start scale up animation when overlay opens
    Future.delayed(Duration(milliseconds: 16), () {
      if (mounted && widget.pressFeedbackController != null) {
        final controller = widget.pressFeedbackController!;

        // Force a reset to break any existing animation state
        controller.reset(); // Go to 0.0 first
        controller.value = 1.0; // Then set to scale down position (animation.value = 0.95)

        // Use the reverse animation with configured duration and curve
        controller.reverse();
      }
    });
  }

  Widget _wrapWithPressFeedbackAnimation(Widget child) {
    if (widget.pressFeedbackAnimation != null) {
      return PressFeedbackAnimationWidget(
        animation: widget.pressFeedbackAnimation!,
        child: child,
      );
    }
    return child;
  }

  @override
  void dispose() {
    // Cancel any pending timers
    _repositioningTimer?.cancel();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _repositionController.dispose();
    _fadeController.dispose();
    _blurController.dispose();
    super.dispose();
  }

  void _calculateRepositioning() {
    // Calculate scaling factor first if needed
    if (widget.scaleDownWhenTooLarge && widget.childSize != null) {
      _calculateScaleFactorBeforeRepositioning();
    }

    final dimensionManager = _createDimensionManager();
    final dimensions = dimensionManager.getWidgetDimensions();

    // Debug: Check if dimensions are ready
    final isReady = dimensionManager.areDimensionsReady(dimensions.top, dimensions.bottom);

    if (!isReady) {
      _scheduleRepositioningRetry();
      return;
    }

    // Reset retry count since we successfully got dimensions
    _repositioningRetryCount = 0;

    // Now calculate the final scaling factor with actual widget dimensions
    if (widget.scaleDownWhenTooLarge && widget.childSize != null) {
      _calculateFinalScaleFactor(dimensions);
    }

    final repositionData = dimensionManager.calculateRepositioning(context);

    if (repositionData.shouldReposition) {
      _applyRepositioning(repositionData);
    } else {
      // Apply scaling animation even if no repositioning is needed
      _applyScalingAnimation();
    }

    setState(() {});
  }

  void _calculateScaleFactorBeforeRepositioning() {
    // Initial estimation for scaling before getting actual widget dimensions
    final screenData = _getScreenData();
    final childSize = widget.childSize!;

    // Estimate widget heights for initial scaling calculation
    final estimatedTopHeight = widget.topWidget != null ? 60.0 : 0.0;
    final estimatedBottomHeight = widget.bottomWidget != null ? 60.0 : 0.0;
    final totalAdditionalHeight = estimatedTopHeight + estimatedBottomHeight;

    // Add reasonable padding between widgets
    final paddingBuffer = widget.topWidget != null && widget.bottomWidget != null ? 20.0 : 10.0;

    // Calculate available space for the child
    final availableHeight = screenData.availableHeight - totalAdditionalHeight - paddingBuffer;
    final availableWidth = MediaQuery.of(context).size.width - widget.screenPadding.horizontal;

    // Simple ratio calculation - no artificial limits
    final heightScaleFactor = availableHeight > 0 ? availableHeight / childSize.height : 1.0;
    final widthScaleFactor = availableWidth > 0 ? availableWidth / childSize.width : 1.0;

    // Use the smaller scale factor to ensure both dimensions fit, but never scale up
    _scaleFactor = [heightScaleFactor, widthScaleFactor, 1.0].reduce((a, b) => a < b ? a : b);

    // Update the scaled child size for positioning calculations
    if (_scaleFactor < 1.0) {
      // Set up scaling animation from the start
      _originalChildSize = childSize;
      _targetChildSize = Size(
        childSize.width * _scaleFactor,
        availableHeight, // Use the exact available height
      );
      _needsScaling = true;

      _scaledChildSize = _targetChildSize;

      // Position the widget to use the full available space between top and bottom
      final topWidgetBottom =
          screenData.screenTop + estimatedTopHeight + (widget.topWidget != null ? paddingBuffer / 2 : 0);

      // Center horizontally
      final screenCenterX = MediaQuery.of(context).size.width / 2;
      _adjustedChildX = screenCenterX - _scaledChildSize!.width / 2;
      _adjustedChildY = topWidgetBottom;
    } else {
      _scaledChildSize = childSize;
      _needsScaling = false;
    }
  }

  void _calculateFinalScaleFactor(({WidgetDimensions top, WidgetDimensions bottom}) dimensions) {
    final screenData = _getScreenData();
    final childSize = widget.childSize!;

    // Calculate total space needed for top and bottom widgets
    final topWidgetHeight = dimensions.top.isValid ? dimensions.top.height : 0.0;
    final bottomWidgetHeight = dimensions.bottom.isValid ? dimensions.bottom.height : 0.0;

    // Add reasonable padding between widgets
    final paddingBuffer = widget.topWidget != null && widget.bottomWidget != null ? 20.0 : 10.0;

    // Calculate available space for the child - this should be the EXACT height we want
    final availableHeight = screenData.availableHeight - topWidgetHeight - bottomWidgetHeight - paddingBuffer;
    final availableWidth = MediaQuery.of(context).size.width - widget.screenPadding.horizontal;

    // Calculate scale factors
    final heightScaleFactor = availableHeight > 0 ? availableHeight / childSize.height : 1.0;
    final widthScaleFactor = availableWidth > 0 ? availableWidth / childSize.width : 1.0;

    // Use the smaller scale factor to ensure both dimensions fit, but never scale up
    final newScaleFactor = [heightScaleFactor, widthScaleFactor, 1.0].reduce((a, b) => a < b ? a : b);

    // Update scale factor if it's different
    if ((newScaleFactor - _scaleFactor).abs() > 0.01) {
      _scaleFactor = newScaleFactor;

      // Update the scaled child size for positioning calculations
      if (_scaleFactor < 1.0) {
        // Set up scaling animation
        _originalChildSize = childSize;
        _targetChildSize = Size(
          childSize.width * _scaleFactor,
          availableHeight, // Use the exact available height, not the proportional one
        );
        _needsScaling = true;

        // Force the widget to use exactly the available height
        _scaledChildSize = _targetChildSize;

        // Position the widget to use the full available space
        final topWidgetBottom =
            screenData.screenTop + topWidgetHeight + (widget.topWidget != null ? paddingBuffer / 2 : 0);

        // Position directly after the top widget (no centering)
        _adjustedChildY = topWidgetBottom;

        // Center horizontally
        final screenCenterX = MediaQuery.of(context).size.width / 2;
        _adjustedChildX = screenCenterX - _scaledChildSize!.width / 2;
      } else {
        _scaledChildSize = childSize;
        _needsScaling = false;
      }
    }
  }

  OverlayDimensionManager _createDimensionManager() {
    final effectiveChildSize =
        widget.scaleDownWhenTooLarge && _scaledChildSize != null ? _scaledChildSize : widget.childSize;

    return OverlayDimensionManager(
      topWidgetKey: _topWidgetKey,
      bottomWidgetKey: _bottomWidgetKey,
      childOffset: widget.childOffset,
      childSize: effectiveChildSize,
      screenPadding: widget.screenPadding,
      topWidgetPadding: widget.topWidgetPadding,
      bottomWidgetPadding: widget.bottomWidgetPadding,
    );
  }

  void _scheduleRepositioningRetry() {
    _repositioningTimer?.cancel();

    // Limit retry attempts to prevent infinite loops
    if (_repositioningRetryCount >= 10) {
      debugPrint('SmartOverlay: Max repositioning retries reached, giving up');
      return;
    }

    _repositioningRetryCount++;

    // Use a slightly longer delay for subsequent retries
    final delay = Duration(milliseconds: 50 + (_repositioningRetryCount * 25));

    _repositioningTimer = Timer(delay, () {
      if (mounted) {
        _calculateRepositioning();
      }
    });
  }

  void _applyRepositioning(RepositionData repositionData) {
    final newY = widget.childOffset.dy + repositionData.topOffset;
    final newX = widget.childOffset.dx;

    setState(() {
      _adjustedChildY = newY;
      _adjustedChildX = newX;
      _needsRepositioning = true;
    });

    _repositionController.forward();
  }

  void _applyScalingAnimation() {
    if (_needsScaling || _needsRepositioning) {
      _repositionController.forward();
    }
  }

  Future<void> _animateToOriginalPositionAndClose() async {
    setState(() {
      _isClosing = true;
    });

    // Start fade animation for top/bottom widgets immediately
    _fadeController.forward();
    // Start blur fade out animation
    _blurController.reverse();

    if (_needsRepositioning || _needsScaling) {
      // Animate main widget back to original position and size
      await _repositionController.reverse();
    } else {
      // If no repositioning or scaling needed, wait for fade to complete
      await _fadeController.forward();
    }

    // Close the overlay
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildBlurBackground(),
            _buildAnimatedChild(),

            // Top widget
            if (widget.topWidget != null) _buildTopWidget(),

            // Bottom widget
            if (widget.bottomWidget != null) _buildBottomWidget(),
          ],
        ),
      ),
    );
  }

  /// Helper methods for building overlay components
  Widget _buildBlurBackground() {
    // Use page animation if available, otherwise use blur animation
    final animationToUse = widget.pageAnimation ?? _blurAnimation;

    return AnimatedBuilder(
      animation: animationToUse,
      builder: (context, child) {
        // Animate blur intensity from 0 to target value
        final animatedBlurSize = (widget.blurSize ?? 4) * animationToUse.value;

        return GestureDetector(
          onTap: _animateToOriginalPositionAndClose,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: animatedBlurSize,
              sigmaY: animatedBlurSize,
            ),
            child: Container(
              color: (widget.blurBackgroundColor ?? Colors.black),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedChild() {
    return AnimatedBuilder(
      animation: _repositionAnimation,
      builder: (context, child) {
        final currentPosition = _calculateCurrentChildPosition();

        Widget childWidget;

        // Calculate current size during animation
        Size currentSize;
        if (widget.scaleDownWhenTooLarge && _needsScaling && _originalChildSize != null && _targetChildSize != null) {
          // Animate between original and target size
          final animationProgress = _repositionAnimation.value;

          if (_isClosing) {
            // During closing: reverse() makes progress go from 1.0 to 0.0
            // When progress = 1.0: target size (scaled)
            // When progress = 0.0: original size
            currentSize = Size(
              _targetChildSize!.width +
                  (_originalChildSize!.width - _targetChildSize!.width) * (1.0 - animationProgress),
              _targetChildSize!.height +
                  (_originalChildSize!.height - _targetChildSize!.height) * (1.0 - animationProgress),
            );
          } else {
            // During opening: forward() makes progress go from 0.0 to 1.0
            // When progress = 0.0: original size
            // When progress = 1.0: target size (scaled)
            currentSize = Size(
              _originalChildSize!.width + (_targetChildSize!.width - _originalChildSize!.width) * animationProgress,
              _originalChildSize!.height + (_targetChildSize!.height - _originalChildSize!.height) * animationProgress,
            );
          }

          // Use FittedBox with animated size
          childWidget = SizedBox(
            width: currentSize.width,
            height: currentSize.height,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: widget.childSize!.width,
                height: widget.childSize!.height,
                child: _wrapWithPressFeedbackAnimation(widget.child),
              ),
            ),
          );
        } else if (widget.scaleDownWhenTooLarge && _scaleFactor < 1.0 && _scaledChildSize != null) {
          // Static scaled state (no animation)
          childWidget = SizedBox(
            width: _scaledChildSize!.width,
            height: _scaledChildSize!.height,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: widget.childSize!.width,
                height: widget.childSize!.height,
                child: _wrapWithPressFeedbackAnimation(widget.child),
              ),
            ),
          );
        } else {
          // Normal unscaled widget
          childWidget = SizedBox(
            width: widget.childSize!.width,
            height: widget.childSize!.height,
            child: _wrapWithPressFeedbackAnimation(widget.child),
          );
        }

        return Positioned(
          top: currentPosition.dy,
          left: currentPosition.dx,
          child: IgnorePointer(
            child: childWidget,
          ),
        );
      },
    );
  }

  Offset _calculateCurrentChildPosition() {
    // If scaling is enabled and we have a scale factor, use the adjusted positions
    if (widget.scaleDownWhenTooLarge && _needsScaling && _scaledChildSize != null) {
      // For scaled widgets with animation, handle position changes during animation
      if (_needsRepositioning) {
        final currentY = _isClosing
            ? _adjustedChildY + (widget.childOffset.dy - _adjustedChildY) * (1 - _repositionAnimation.value)
            : widget.childOffset.dy + (_adjustedChildY - widget.childOffset.dy) * _repositionAnimation.value;

        final currentX = _isClosing
            ? _adjustedChildX + (widget.childOffset.dx - _adjustedChildX) * (1 - _repositionAnimation.value)
            : widget.childOffset.dx + (_adjustedChildX - widget.childOffset.dx) * _repositionAnimation.value;

        return Offset(currentX, currentY);
      } else {
        // Animate from original position to scaled position
        final currentY = _isClosing
            ? _adjustedChildY + (widget.childOffset.dy - _adjustedChildY) * (1 - _repositionAnimation.value)
            : widget.childOffset.dy + (_adjustedChildY - widget.childOffset.dy) * _repositionAnimation.value;

        final currentX = _isClosing
            ? _adjustedChildX + (widget.childOffset.dx - _adjustedChildX) * (1 - _repositionAnimation.value)
            : widget.childOffset.dx + (_adjustedChildX - widget.childOffset.dx) * _repositionAnimation.value;

        return Offset(currentX, currentY);
      }
    }

    // Original positioning logic for non-scaled widgets
    final currentY = _needsRepositioning
        ? _isClosing
            ? _adjustedChildY + (widget.childOffset.dy - _adjustedChildY) * (1 - _repositionAnimation.value)
            : widget.childOffset.dy + (_adjustedChildY - widget.childOffset.dy) * _repositionAnimation.value
        : widget.childOffset.dy;

    final currentX = _needsRepositioning
        ? _isClosing
            ? _adjustedChildX + (widget.childOffset.dx - _adjustedChildX) * (1 - _repositionAnimation.value)
            : widget.childOffset.dx + (_adjustedChildX - widget.childOffset.dx) * _repositionAnimation.value
        : widget.childOffset.dx;

    return Offset(currentX, currentY);
  }

  ({double top, double left}) _calculateTopWidgetPosition(Offset currentChildPosition) {
    final screenData = _getScreenData();
    final topWidgetHeight = _getWidgetHeight(_topWidgetKey, widget.topWidgetPadding);
    final effectiveChildSize =
        widget.scaleDownWhenTooLarge && _scaledChildSize != null ? _scaledChildSize! : widget.childSize ?? Size.zero;

    final topPosition = OverlayPositionCalculator.calculateTopWidgetPosition(
      currentChildY: currentChildPosition.dy,
      topWidgetHeight: topWidgetHeight,
      screenTop: screenData.screenTop,
      childHeight: effectiveChildSize.height,
      availableHeight: screenData.availableHeight,
    );

    final leftPosition = OverlayPositionCalculator.calculateLeftPosition(
      currentChildX: currentChildPosition.dx,
      childSize: effectiveChildSize,
      alignment: widget.topWidgetAlignment,
    );

    return (top: topPosition, left: leftPosition);
  }

  ({double top, double left}) _calculateBottomWidgetPosition(Offset currentChildPosition) {
    final screenData = _getScreenData();
    final bottomWidgetHeight = _getWidgetHeight(_bottomWidgetKey, widget.bottomWidgetPadding);
    final effectiveChildSize =
        widget.scaleDownWhenTooLarge && _scaledChildSize != null ? _scaledChildSize! : widget.childSize ?? Size.zero;

    final topPosition = OverlayPositionCalculator.calculateBottomWidgetPosition(
      currentChildY: currentChildPosition.dy,
      childHeight: effectiveChildSize.height,
      bottomWidgetHeight: bottomWidgetHeight,
      screenBottom: screenData.screenBottom,
      availableHeight: screenData.availableHeight,
    );

    final leftPosition = OverlayPositionCalculator.calculateLeftPosition(
      currentChildX: currentChildPosition.dx,
      childSize: effectiveChildSize,
      alignment: widget.bottomWidgetAlignment,
    );

    return (top: topPosition, left: leftPosition);
  }

  ({double screenTop, double screenBottom, double availableHeight}) _getScreenData() {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    final screenBottom = screenSize.height - safeArea.bottom - widget.screenPadding.bottom;
    final screenTop = safeArea.top + widget.screenPadding.top;
    final availableHeight = screenBottom - screenTop;

    return (
      screenTop: screenTop,
      screenBottom: screenBottom,
      availableHeight: availableHeight,
    );
  }

  double _getWidgetHeight(GlobalKey key, EdgeInsets? padding) {
    final context = key.currentContext;
    if (context == null) return 0.0;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return 0.0;

    return renderBox.size.height + (padding?.vertical ?? 0);
  }

  Widget _buildTopWidget() {
    return AnimatedBuilder(
      animation: _repositionAnimation,
      builder: (context, child) {
        final currentChildPosition = _calculateCurrentChildPosition();
        final position = _calculateTopWidgetPosition(currentChildPosition);
        final effectiveChildSize =
            widget.scaleDownWhenTooLarge && _scaledChildSize != null ? _scaledChildSize : widget.childSize;

        return OverlayWidgetBuilders.buildTopWidget(
          widgetKey: _topWidgetKey,
          widget: widget.topWidget!,
          padding: widget.topWidgetPadding,
          alignment: widget.topWidgetAlignment,
          childSize: effectiveChildSize,
          leftPosition: position.left,
          topPosition: position.top,
          repositionAnimation: _repositionAnimation,
          fadeAnimation: _fadeAnimation,
          isClosing: _isClosing,
          animationCurve: widget.topWidgetAnimationCurve,
        );
      },
    );
  }

  Widget _buildBottomWidget() {
    return AnimatedBuilder(
      animation: _repositionAnimation,
      builder: (context, child) {
        final currentChildPosition = _calculateCurrentChildPosition();
        final position = _calculateBottomWidgetPosition(currentChildPosition);
        final effectiveChildSize =
            widget.scaleDownWhenTooLarge && _scaledChildSize != null ? _scaledChildSize : widget.childSize;

        return OverlayWidgetBuilders.buildBottomWidget(
          widgetKey: _bottomWidgetKey,
          widget: widget.bottomWidget!,
          padding: widget.bottomWidgetPadding,
          alignment: widget.bottomWidgetAlignment,
          childSize: effectiveChildSize,
          leftPosition: position.left,
          topPosition: position.top,
          repositionAnimation: _repositionAnimation,
          fadeAnimation: _fadeAnimation,
          isClosing: _isClosing,
          animationCurve: widget.bottomWidgetAnimationCurve,
        );
      },
    );
  }
}
