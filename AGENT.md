# AGENT.md - smart_overlay_menu Flutter Package

## Commands

- **Build**: `flutter pub get && flutter build`
- **Test**: `flutter test` (all tests), `flutter test test/specific_test.dart` (single test file)
- **Lint**: `flutter analyze`
- **Format**: `dart format .`
- **Example**: `cd example && flutter run`

## Architecture

- **Package**: Flutter plugin providing overlay menu widgets
- **Main API**: `SmartOverlayHolder` widget with customizable top/bottom overlays
- **Structure**: `lib/src/widgets/` contains core components
- **Key Files**: `smart_overlay_holder.dart`, `smart_overlay_details.dart`, `figma_curve.dart`
- **Export**: Single entry point via `lib/smart_overlay_menu.dart`

## Code Style

- **Imports**: Flutter/material imports first, then package imports, then relative imports
- **Naming**: PascalCase for classes, camelCase for variables/methods, snake_case for files
- **Widgets**: Prefer StatefulWidget for interactive components, controller pattern for external control
- **Parameters**: Use named parameters, nullable types with `?`, default values where appropriate
- **Animation**: Use Flutter's built-in animation controllers and curves
