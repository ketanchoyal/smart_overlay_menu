import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_overlay_menu/src/utils/positioning_calculator.dart';

void main() {
  group('WidgetDimensions', () {
    test('should create valid dimensions', () {
      const dimensions = WidgetDimensions(height: 100, width: 200, isValid: true);
      
      expect(dimensions.height, equals(100));
      expect(dimensions.width, equals(200));
      expect(dimensions.isValid, isTrue);
    });

    test('should have invalid constant', () {
      expect(WidgetDimensions.invalid.height, equals(0.0));
      expect(WidgetDimensions.invalid.width, equals(0.0));
      expect(WidgetDimensions.invalid.isValid, isFalse);
    });
  });

  group('RepositionData', () {
    test('should create reposition data correctly', () {
      const data = RepositionData(topOffset: 10, leftOffset: 20, shouldReposition: true);
      
      expect(data.topOffset, equals(10));
      expect(data.leftOffset, equals(20));
      expect(data.shouldReposition, isTrue);
    });

    test('should have none constant', () {
      expect(RepositionData.none.topOffset, equals(0.0));
      expect(RepositionData.none.leftOffset, equals(0.0));
      expect(RepositionData.none.shouldReposition, isFalse);
    });
  });

  group('PositioningCalculator', () {
    testWidgets('should get invalid dimensions for null context', (WidgetTester tester) async {
      final key = GlobalKey();
      final dimensions = PositioningCalculator.getWidgetDimensions(key, null);
      
      expect(dimensions.isValid, isFalse);
    });

    group('calculateReposition', () {
      const screenSize = Size(400, 800);
      const safeArea = EdgeInsets.only(top: 50, bottom: 30);
      const screenPadding = EdgeInsets.all(16);
      const childSize = Size(100, 50);
      
      test('should return none when childSize is null', () {
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(100, 100),
          childSize: null,
          screenPadding: screenPadding,
          topWidget: WidgetDimensions.invalid,
          bottomWidget: WidgetDimensions.invalid,
        );
        
        expect(result, equals(RepositionData.none));
      });

      test('should calculate top overflow correctly', () {
        const topWidget = WidgetDimensions(height: 80, width: 100, isValid: true);
        
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(100, 70), // Too close to top
          childSize: childSize,
          screenPadding: screenPadding,
          topWidget: topWidget,
          bottomWidget: WidgetDimensions.invalid,
        );
        
        expect(result.shouldReposition, isTrue);
        expect(result.topOffset, greaterThan(0)); // Should move down
      });

      test('should calculate bottom overflow correctly', () {
        const bottomWidget = WidgetDimensions(height: 80, width: 100, isValid: true);
        
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(100, 700), // Too close to bottom
          childSize: childSize,
          screenPadding: screenPadding,
          topWidget: WidgetDimensions.invalid,
          bottomWidget: bottomWidget,
        );
        
        expect(result.shouldReposition, isTrue);
        expect(result.topOffset, lessThan(0)); // Should move up
      });

      test('should handle tall container correctly', () {
        const tallChildSize = Size(100, 900); // Taller than screen
        
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(100, 200),
          childSize: tallChildSize,
          screenPadding: screenPadding,
          topWidget: WidgetDimensions.invalid,
          bottomWidget: WidgetDimensions.invalid,
        );
        
        expect(result.shouldReposition, isTrue);
        expect(result.topOffset, lessThan(0)); // Should move to top
      });

      test('should calculate left overflow correctly', () {
        const topWidget = WidgetDimensions(height: 50, width: 150, isValid: true);
        
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(10, 200), // Too close to left
          childSize: childSize,
          screenPadding: screenPadding,
          topWidget: topWidget,
          bottomWidget: WidgetDimensions.invalid,
        );
        
        expect(result.shouldReposition, isTrue);
        expect(result.leftOffset, greaterThan(0)); // Should move right
      });

      test('should calculate right overflow correctly', () {
        const bottomWidget = WidgetDimensions(height: 50, width: 200, isValid: true);
        
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(350, 200), // Too close to right
          childSize: childSize,
          screenPadding: screenPadding,
          topWidget: WidgetDimensions.invalid,
          bottomWidget: bottomWidget,
        );
        
        expect(result.shouldReposition, isTrue);
        expect(result.leftOffset, lessThan(0)); // Should move left
      });

      test('should handle no overflow case', () {
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(200, 400), // Well positioned
          childSize: childSize,
          screenPadding: screenPadding,
          topWidget: WidgetDimensions(height: 30, width: 80, isValid: true),
          bottomWidget: WidgetDimensions(height: 30, width: 80, isValid: true),
        );
        
        expect(result.shouldReposition, isFalse);
        expect(result.topOffset, equals(0));
        expect(result.leftOffset, equals(0));
      });

      test('should handle both horizontal and vertical overflow', () {
        const largeWidget = WidgetDimensions(height: 100, width: 250, isValid: true);
        
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(10, 70), // Near top-left corner
          childSize: childSize,
          screenPadding: screenPadding,
          topWidget: largeWidget,
          bottomWidget: largeWidget,
        );
        
        expect(result.shouldReposition, isTrue);
        expect(result.topOffset, greaterThan(0)); // Should move down
        expect(result.leftOffset, greaterThan(0)); // Should move right
      });

      test('should handle zero screen padding', () {
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: safeArea,
          childOffset: Offset(50, 60),
          childSize: childSize,
          screenPadding: EdgeInsets.zero,
          topWidget: WidgetDimensions(height: 50, width: 100, isValid: true),
          bottomWidget: WidgetDimensions.invalid,
        );
        
        // Should still work without screen padding
        expect(result, isNotNull);
      });

      test('should handle zero safe area', () {
        final result = PositioningCalculator.calculateReposition(
          screenSize: screenSize,
          safeArea: EdgeInsets.zero,
          childOffset: Offset(100, 100),
          childSize: childSize,
          screenPadding: screenPadding,
          topWidget: WidgetDimensions(height: 50, width: 100, isValid: true),
          bottomWidget: WidgetDimensions.invalid,
        );
        
        // Should still work without safe area
        expect(result, isNotNull);
      });
    });
  });
}
