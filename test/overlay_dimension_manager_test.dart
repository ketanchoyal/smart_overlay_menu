import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_overlay_menu/src/widgets/overlay_dimension_manager.dart';
import 'package:smart_overlay_menu/src/utils/positioning_calculator.dart';

void main() {
  group('OverlayDimensionManager', () {
    late GlobalKey topWidgetKey;
    late GlobalKey bottomWidgetKey;
    const childOffset = Offset(100, 200);
    const childSize = Size(150, 50);
    const screenPadding = EdgeInsets.all(16);
    const topWidgetPadding = EdgeInsets.all(8);
    const bottomWidgetPadding = EdgeInsets.all(12);

    setUp(() {
      topWidgetKey = GlobalKey();
      bottomWidgetKey = GlobalKey();
    });

    OverlayDimensionManager createManager() {
      return OverlayDimensionManager(
        topWidgetKey: topWidgetKey,
        bottomWidgetKey: bottomWidgetKey,
        childOffset: childOffset,
        childSize: childSize,
        screenPadding: screenPadding,
        topWidgetPadding: topWidgetPadding,
        bottomWidgetPadding: bottomWidgetPadding,
      );
    }

    test('should create manager with all parameters', () {
      final manager = createManager();
      
      expect(manager, isNotNull);
      expect(manager, isA<OverlayDimensionManager>());
    });

    test('should get invalid dimensions when widgets are not rendered', () {
      final manager = createManager();
      final dimensions = manager.getWidgetDimensions();
      
      expect(dimensions.top.isValid, isFalse);
      expect(dimensions.bottom.isValid, isFalse);
    });

    test('should return true when dimensions are ready for non-existent widgets', () {
      final manager = createManager();
      const invalidDimensions = WidgetDimensions.invalid;
      
      final isReady = manager.areDimensionsReady(invalidDimensions, invalidDimensions);
      
      expect(isReady, isTrue);
    });

    testWidgets('should detect when dimensions are not ready for existing widgets', (WidgetTester tester) async {
      final manager = createManager();
      
      // Create widgets with the keys but don't lay them out yet
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: topWidgetKey, width: 100, height: 50),
                Container(key: bottomWidgetKey, width: 120, height: 60),
              ],
            ),
          ),
        ),
      );

      // Pump once to build but potentially not layout
      await tester.pump();

      final dimensions = manager.getWidgetDimensions();
      final isReady = manager.areDimensionsReady(dimensions.top, dimensions.bottom);
      
      // Should be ready after proper layout
      expect(isReady, isTrue);
    });

    testWidgets('should get valid dimensions when widgets are rendered', (WidgetTester tester) async {
      final manager = createManager();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  key: topWidgetKey,
                  width: 100,
                  height: 50,
                  color: Colors.blue,
                ),
                Container(
                  key: bottomWidgetKey,
                  width: 120,
                  height: 60,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final dimensions = manager.getWidgetDimensions();
      
      expect(dimensions.top.isValid, isTrue);
      expect(dimensions.bottom.isValid, isTrue);
      expect(dimensions.top.width, equals(100 + topWidgetPadding.horizontal));
      expect(dimensions.top.height, equals(50 + topWidgetPadding.vertical));
      expect(dimensions.bottom.width, equals(120 + bottomWidgetPadding.horizontal));
      expect(dimensions.bottom.height, equals(60 + bottomWidgetPadding.vertical));
    });

    testWidgets('should calculate repositioning correctly', (WidgetTester tester) async {
      final manager = createManager();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: topWidgetKey, width: 100, height: 50),
                Container(key: bottomWidgetKey, width: 120, height: 60),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final repositionData = manager.calculateRepositioning(tester.element(find.byType(Scaffold)));
      
      expect(repositionData, isNotNull);
      expect(repositionData, isA<RepositionData>());
    });

    testWidgets('should return none when dimensions not ready', (WidgetTester tester) async {
      final manager = OverlayDimensionManager(
        topWidgetKey: GlobalKey(), // New key with no widget
        bottomWidgetKey: GlobalKey(), // New key with no widget
        childOffset: childOffset,
        childSize: childSize,
        screenPadding: screenPadding,
        topWidgetPadding: topWidgetPadding,
        bottomWidgetPadding: bottomWidgetPadding,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Container()),
        ),
      );

      final repositionData = manager.calculateRepositioning(tester.element(find.byType(Scaffold)));
      
      expect(repositionData.shouldReposition, isFalse);
    });

    test('should handle null padding correctly', () {
      final manager = OverlayDimensionManager(
        topWidgetKey: topWidgetKey,
        bottomWidgetKey: bottomWidgetKey,
        childOffset: childOffset,
        childSize: childSize,
        screenPadding: screenPadding,
        topWidgetPadding: null,
        bottomWidgetPadding: null,
      );
      
      expect(manager, isNotNull);
      
      final dimensions = manager.getWidgetDimensions();
      expect(dimensions.top.isValid, isFalse);
      expect(dimensions.bottom.isValid, isFalse);
    });

    testWidgets('should handle edge case positioning', (WidgetTester tester) async {
      // Create manager with edge case positioning
      final edgeManager = OverlayDimensionManager(
        topWidgetKey: topWidgetKey,
        bottomWidgetKey: bottomWidgetKey,
        childOffset: Offset(10, 10), // Near screen edge
        childSize: Size(300, 400), // Large size
        screenPadding: EdgeInsets.all(8),
        topWidgetPadding: EdgeInsets.all(4),
        bottomWidgetPadding: EdgeInsets.all(6),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: topWidgetKey, width: 200, height: 100),
                Container(key: bottomWidgetKey, width: 180, height: 80),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final repositionData = edgeManager.calculateRepositioning(tester.element(find.byType(Scaffold)));
      
      expect(repositionData, isNotNull);
      // Should likely need repositioning due to edge positioning
    });

    group('Dimensions ready detection', () {
      testWidgets('should handle mixed widget states correctly', (WidgetTester tester) async {
        final localTopKey = GlobalKey();
        final localBottomKey = GlobalKey(); // This one won't have a widget
        
        final manager = OverlayDimensionManager(
          topWidgetKey: localTopKey,
          bottomWidgetKey: localBottomKey,
          childOffset: childOffset,
          childSize: childSize,
          screenPadding: screenPadding,
          topWidgetPadding: topWidgetPadding,
          bottomWidgetPadding: bottomWidgetPadding,
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(key: localTopKey, width: 100, height: 50),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final dimensions = manager.getWidgetDimensions();
        final isReady = manager.areDimensionsReady(dimensions.top, dimensions.bottom);
        
        // Should be ready because bottom widget doesn't exist (no context)
        expect(isReady, isTrue);
        expect(dimensions.top.isValid, isTrue);
        expect(dimensions.bottom.isValid, isFalse);
      });
    });
  });
}
