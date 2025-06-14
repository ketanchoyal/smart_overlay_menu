# Focused Menu

A Flutter package that provides a generic component for displaying custom overlays on long press (or tap) with automatic repositioning and haptic feedback.

> **Note:** This package is inspired by [focused_menu](https://pub.dev/packages/focused_menu) package by [retroportalstudio.com](https://retroportalstudio.com).

![Pub Version](https://img.shields.io/pub/v/smart_overlay_menu.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Demonstration

Here's how the focused menu looks in action, as implemented in [Dragonfly](https://dfly.app), a native macOS/iOS client for Bluesky:

![Focused Menu Demo in Dragonfly](assets/dragonfly-demo.gif)

## Features

- **Customizable Widgets**: Accepts any widget for top and bottom positions
- **Widget Alignment**: Control horizontal alignment of top and bottom widgets (left, center, right)
- **Press Feedback**: Visual feedback animation when long pressing widgets
- **Automatic Repositioning**: Automatically moves the main widget if overlays exceed screen boundaries
- **Automatic Scaling**: Scale down oversized widgets to fit available space with smooth animations
- **Smooth Animations**: Repositioning, scaling, and widget appearance animations
- **Programmatic Control**: Ability to open/close overlay via controller
- **Haptic Feedback**: Built-in haptic feedback with customization options
- **Flexible**: Support for top-only, bottom-only, or both widgets

## Installation

Add this line to your `pubspec.yaml` file:

```yaml
dependencies:
  smart_overlay_menu: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Basic Usage

```dart
import 'package:smart_overlay_menu/smart_overlay_menu.dart';

FocusedOverlayHolder(
  topWidget: Container(
    padding: EdgeInsets.all(16),
    color: Colors.blue,
    child: Text('Top Widget'),
  ),
  bottomWidget: Container(
    padding: EdgeInsets.all(16),
    color: Colors.red,
    child: Text('Bottom Widget'),
  ),
  child: Container(
    padding: EdgeInsets.all(20),
    color: Colors.green,
    child: Text('Long press me!'),
  ),
)
```

## Automatic Repositioning

The component automatically detects when widgets overflow the screen and repositions the main widget with smooth animation:

- If the `bottomWidget` exceeds the bottom of the screen, the main widget moves up
- If the `topWidget` exceeds the top of the screen, the main widget moves down

## Automatic Scaling for Large Widgets

When the main widget (child) is too large to fit on screen between top and bottom widgets, you can enable automatic scaling:

```dart
FocusedOverlayHolder(
  scaleDownWhenTooLarge: true, // Enable automatic scaling
  topWidget: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('Top Widget'),
  ),
  bottomWidget: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('Bottom Widget'),
  ),
  child: Container(
    width: 300,
    height: 1000, // Very tall widget
    color: Colors.green,
    child: Text('This widget is too tall!'),
  ),
)
```

When `scaleDownWhenTooLarge` is enabled:

1. **Size calculation** → Automatically calculates available space between top and bottom widgets
2. **Uniform scaling** → Scales the widget proportionally to fit the available space
3. **Smooth animation** → Animates from original size to scaled size on open, and back on close
4. **Perfect positioning** → Centers the scaled widget horizontally and positions it between overlay widgets

**Note:** This feature maintains the widget's aspect ratio and only scales down when necessary (never scales up).

## Widget Alignment

Control the horizontal alignment of top and bottom widgets relative to the main child widget:

```dart
// Left aligned (default)
FocusedOverlayHolder(
  topWidgetAlignment: Alignment.centerLeft,
  bottomWidgetAlignment: Alignment.centerLeft,
  topWidget: Text('Left aligned'),
  bottomWidget: Text('Left aligned'),
  child: Container(width: 200, child: Text('Main widget')),
)

// Right aligned
FocusedOverlayHolder(
  topWidgetAlignment: Alignment.centerRight,
  bottomWidgetAlignment: Alignment.centerRight,
  topWidget: Text('Right aligned'),
  bottomWidget: Text('Right aligned'),
  child: Container(width: 200, child: Text('Main widget')),
)

// Center aligned
FocusedOverlayHolder(
  topWidgetAlignment: Alignment.center,
  bottomWidgetAlignment: Alignment.center,
  topWidget: Text('Center aligned'),
  bottomWidget: Text('Center aligned'),
  child: Container(width: 200, child: Text('Main widget')),
)

// Mixed alignment
FocusedOverlayHolder(
  topWidgetAlignment: Alignment.centerLeft,
  bottomWidgetAlignment: Alignment.centerRight,
  topWidget: Text('Left top'),
  bottomWidget: Text('Right bottom'),
  child: Container(width: 200, child: Text('Main widget')),
)
```

## Press Feedback

Provide visual feedback when users long press (or tap) widgets with customizable scaling animation:

```dart
// Default press feedback (0.9 scale, 200ms)
FocusedOverlayHolder(
  bottomWidget: Text('Menu item'),
  child: Text('Long press me'),
)

// Custom press feedback
FocusedOverlayHolder(
  pressFeedbackScale: 0.8,           // Scale down to 80%
  pressFeedbackDuration: Duration(milliseconds: 300), // 300ms animation
  bottomWidget: Text('Menu item'),
  child: Text('Long press me'),
)

// Subtle press feedback
FocusedOverlayHolder(
  pressFeedbackScale: 0.95,          // Scale down to 95%
  pressFeedbackDuration: Duration(milliseconds: 150), // 150ms animation
  bottomWidget: Text('Menu item'),
  child: Text('Long press me'),
)

// Custom reverse animation (scale up in overlay)
FocusedOverlayHolder(
  pressFeedbackScale: 0.85,          // Scale down to 85%
  pressFeedbackDuration: Duration(milliseconds: 500), // Slow scale down
  pressFeedbackReverseDuration: Duration(milliseconds: 800), // Slow scale up
  pressFeedbackReverseCurve: Curves.elasticOut, // Bouncy scale up
  bottomWidget: Text('Menu item'),
  child: Text('Long press me'),
)
```

The press feedback animation:

1. **Long press detected** → Automatically triggers press animation
2. **Scales down** → Widget compresses (like a button press) with configurable duration
3. **Opens overlay** → Menu appears with blur background
4. **Scales back up** → Widget returns to normal size in overlay with configurable reverse duration and curve

## Animation Curves

Customize the animation curves for different parts of the overlay system for fine-tuned control over the animation feel:

```dart
FocusedOverlayHolder(
  // Custom repositioning animation curve
  repositionAnimationCurve: Curves.easeInOutBack,
  repositionAnimationDuration: Duration(milliseconds: 400),

  // Custom top widget animation curve
  topWidgetAnimationCurve: Curves.bounceOut,

  // Custom bottom widget animation curve
  bottomWidgetAnimationCurve: Curves.elasticOut,

  topWidget: Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
    child: Text('Edit', style: TextStyle(color: Colors.white)),
  ),
  bottomWidget: Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
    child: Text('Delete', style: TextStyle(color: Colors.white)),
  ),
  child: Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('Custom animations!'),
    ),
  ),
)
```

Available animation curve types:

- **repositionAnimationCurve**: Controls the animation when the main widget repositions to avoid screen overflow
- **topWidgetAnimationCurve**: Controls the scale and fade animation of the top overlay widget
- **bottomWidgetAnimationCurve**: Controls the scale and fade animation of the bottom overlay widget

The package includes custom `FigmaSpringCurve` animations (slow, gentle, quick, bouncy) that provide natural, design-focused motion curves.

## Programmatic Control

```dart
final controller = FocusedOverlayHolderController();

// Open overlay
controller.open();

// Close overlay
controller.close();

FocusedOverlayHolder(
  controller: controller,
  bottomWidget: MyCustomWidget(),
  child: Text('Controlled Widget'),
)
```

## Haptic Feedback

The component provides haptic feedback by default when opening the overlay. You can customize or disable it:

```dart
// Default usage (light impact)
FocusedOverlayHolder(
  child: Text('Default haptic'),
  bottomWidget: MyWidget(),
)

// Custom haptic
FocusedOverlayHolder(
  haptic: HapticFeedback.mediumImpact,
  child: Text('Medium haptic'),
  bottomWidget: MyWidget(),
)

// Disable haptic
FocusedOverlayHolder(
  haptic: null,
  child: Text('No haptic'),
  bottomWidget: MyWidget(),
)
```

## Available Parameters

| Parameter                     | Type                              | Description                           | Default                      |
| ----------------------------- | --------------------------------- | ------------------------------------- | ---------------------------- |
| `child`                       | `Widget`                          | The main widget (required)            | -                            |
| `topWidget`                   | `Widget?`                         | Widget to display above (optional)    | `null`                       |
| `bottomWidget`                | `Widget?`                         | Widget to display below (optional)    | `null`                       |
| `topWidgetPadding`            | `EdgeInsets?`                     | Padding around top widget             | `null`                       |
| `bottomWidgetPadding`         | `EdgeInsets?`                     | Padding around bottom widget          | `null`                       |
| `topWidgetAlignment`          | `Alignment?`                      | Horizontal alignment of top widget    | `Alignment.centerLeft`       |
| `bottomWidgetAlignment`       | `Alignment?`                      | Horizontal alignment of bottom widget | `Alignment.centerLeft`       |
| `pressFeedbackScale`          | `double?`                         | Scale factor for press feedback       | `0.9`                        |
| `pressFeedbackDuration`       | `Duration?`                       | Duration of press feedback animation  | `200ms`                      |
| `pressFeedbackReverseDuration`| `Duration?`                       | Duration of reverse animation in overlay | `300ms`                   |
| `pressFeedbackReverseCurve`   | `Curve?`                          | Curve for reverse animation in overlay | `Curves.easeInOut`           |
| `openWithTap`                 | `bool`                            | Open with tap instead of long press   | `false`                      |
| `repositionAnimationDuration` | `Duration?`                       | Duration of repositioning animation   | `300ms`                      |
| `repositionAnimationCurve`    | `Curve?`                          | Animation curve for repositioning     | `FigmaSpringCurve.slow`      |
| `topWidgetAnimationCurve`     | `Curve?`                          | Animation curve for top widget        | `FigmaSpringCurve.bouncy`    |
| `bottomWidgetAnimationCurve`  | `Curve?`                          | Animation curve for bottom widget     | `FigmaSpringCurve.bouncy`    |
| `blurSize`                    | `double?`                         | Background blur intensity             | `null`                       |
| `blurBackgroundColor`         | `Color?`                          | Blurred background color              | `null`                       |
| `haptic`                      | `VoidCallback?`                   | Haptic feedback on open               | `HapticFeedback.lightImpact` |
| `onOpened`                    | `VoidCallback?`                   | Callback when overlay opens           | `null`                       |
| `onClosed`                    | `VoidCallback?`                   | Callback when overlay closes          | `null`                       |
| `controller`                  | `FocusedOverlayHolderController?` | Controller for programmatic control   | `null`                       |
| `screenPadding`               | `EdgeInsets?`                     | Screen padding for positioning        | `EdgeInsets.all(16.0)`       |
| `scaleDownWhenTooLarge`       | `bool`                            | Auto-scale widget when too large      | `false`                      |

## Advanced Example

```dart
FocusedOverlayHolder(
  openWithTap: true,
  haptic: HapticFeedback.mediumImpact,
  repositionAnimationDuration: Duration(milliseconds: 500),
  repositionAnimationCurve: Curves.easeInOutBack,
  topWidgetAnimationCurve: Curves.bounceOut,
  bottomWidgetAnimationCurve: Curves.elasticOut,
  screenPadding: EdgeInsets.all(20),
  topWidgetAlignment: Alignment.centerRight,
  bottomWidgetAlignment: Alignment.center,
  pressFeedbackScale: 0.85,
  pressFeedbackDuration: Duration(milliseconds: 250),
  scaleDownWhenTooLarge: true,
  topWidget: Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.edit, color: Colors.white),
        Text('Edit', style: TextStyle(color: Colors.white)),
      ],
    ),
  ),
  bottomWidget: Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.delete, color: Colors.white),
        Text('Delete', style: TextStyle(color: Colors.white)),
      ],
    ),
  ),
  onOpened: () => print('Overlay opened'),
  onClosed: () => print('Overlay closed'),
  child: Card(
    child: Container(
      width: 200,
      padding: EdgeInsets.all(16),
      child: Text('Tap me!', textAlign: TextAlign.center),
    ),
  ),
)
```

## Example

Check out the [example/](example/) folder for a complete demonstration of all features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

### MIT License with Attribution Requirement

Copyright © 2025 Sébastien Gruhier (asyncdev.com) and Inès Gruhier (odubu.design)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software, including the rights to use, copy, modify, merge, publish, and/or distribute copies of the Software, subject to the following conditions:

1. **Attribution Requirement**: Any use, modification, or distribution of the Software must include clear and visible attribution to the original authors:

   - [Sébastien Gruhier](https://asyncdev.com) for development
   - [Inès Gruhier](https://odubu.design) for design

2. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
