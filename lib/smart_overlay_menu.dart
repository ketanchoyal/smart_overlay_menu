/// A Flutter package that provides customizable overlay menus with haptic feedback,
/// automatic positioning, smooth animations, and programmatic control.
///
/// This library exports the main [SmartOverlayHolder] widget and its controller
/// for creating professional overlay menus in Flutter applications.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:smart_overlay_menu/smart_overlay_menu.dart';
///
/// SmartOverlayHolder(
///   topWidget: Container(
///     padding: EdgeInsets.all(16),
///     decoration: BoxDecoration(
///       color: Colors.blue,
///       borderRadius: BorderRadius.circular(8),
///     ),
///     child: Text('Edit', style: TextStyle(color: Colors.white)),
///   ),
///   bottomWidget: Container(
///     padding: EdgeInsets.all(16),
///     decoration: BoxDecoration(
///       color: Colors.red,
///       borderRadius: BorderRadius.circular(8),
///     ),
///     child: Text('Delete', style: TextStyle(color: Colors.white)),
///   ),
///   child: Container(
///     padding: EdgeInsets.all(20),
///     decoration: BoxDecoration(
///       color: Colors.green,
///       borderRadius: BorderRadius.circular(8),
///     ),
///     child: Text('Long press me!', style: TextStyle(color: Colors.white)),
///   ),
/// )
/// ```
///
/// ## Features
///
/// - **Customizable Widgets**: Accept any widget for top and bottom positions
/// - **Widget Alignment**: Control horizontal alignment of overlay widgets
/// - **Press Feedback**: Visual feedback animation when pressing widgets
/// - **Automatic Repositioning**: Automatically repositions when overlays exceed screen boundaries
/// - **Smooth Animations**: Repositioning and widget appearance animations
/// - **Programmatic Control**: Open/close overlay via [SmartOverlayHolderController]
/// - **Haptic Feedback**: Built-in haptic feedback with customization options
/// - **Flexible**: Support for top-only, bottom-only, or both widgets
library smart_overlay_menu;

export 'package:smart_overlay_menu/src/widgets/smart_overlay_menu.dart';
