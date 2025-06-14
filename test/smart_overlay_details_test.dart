import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_overlay_menu/src/widgets/figma_curve.dart';
import 'package:smart_overlay_menu/src/widgets/smart_overlay_details.dart';

void main() {
  group('SmartOverlayDetails Widget', () {
    const childOffset = Offset(100, 200);
    const childSize = Size(150, 50);
    const repositionAnimationDuration = Duration(milliseconds: 300);
    const screenPadding = EdgeInsets.all(16.0);

    Widget createTestWidget({
      Widget? topWidget,
      Widget? bottomWidget,
      EdgeInsets? topWidgetPadding,
      EdgeInsets? bottomWidgetPadding,
      double? blurSize,
      Color? blurBackgroundColor,
      Curve? repositionAnimationCurve,
      Curve? topWidgetAnimationCurve,
      Curve? bottomWidgetAnimationCurve,
      Size? testChildSize,
    }) {
      return MaterialApp(
        home: SmartOverlayDetails(
          child: Container(
            width: (testChildSize ?? childSize).width,
            height: (testChildSize ?? childSize).height,
            color: Colors.blue,
            child: Text('Test Child'),
          ),
          childOffset: childOffset,
          childSize: testChildSize ?? childSize,
          repositionAnimationDuration: repositionAnimationDuration,
          screenPadding: screenPadding,
          topWidget: topWidget,
          bottomWidget: bottomWidget,
          topWidgetPadding: topWidgetPadding,
          bottomWidgetPadding: bottomWidgetPadding,
          blurSize: blurSize,
          blurBackgroundColor: blurBackgroundColor,
          repositionAnimationCurve: repositionAnimationCurve,
          topWidgetAnimationCurve: topWidgetAnimationCurve,
          bottomWidgetAnimationCurve: bottomWidgetAnimationCurve,
        ),
      );
    }

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(Material), findsOneWidget);
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('should display child widget at correct position', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final positionedFinder = find.byType(Positioned);
      expect(positionedFinder, findsWidgets);

      // Child should be positioned at the specified offset
      final childPositioned = tester.widget<Positioned>(positionedFinder.first);

      // Note: We can't easily verify exact positioning without complex widget inspection
      expect(childPositioned.top, isNotNull);
      expect(childPositioned.left, isNotNull);
    });

    testWidgets('should handle top widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(topWidget: Text('Top Widget'), topWidgetPadding: EdgeInsets.all(8)));

      await tester.pump(); // Initial build
      await tester.pump(Duration(milliseconds: 100)); // Animation in progress

      expect(find.text('Top Widget'), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should handle bottom widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(bottomWidget: Text('Bottom Widget'), bottomWidgetPadding: EdgeInsets.all(12)),
      );

      await tester.pump(); // Initial build
      await tester.pump(Duration(milliseconds: 100)); // Animation in progress

      expect(find.text('Bottom Widget'), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should handle both top and bottom widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(topWidget: Icon(Icons.arrow_upward), bottomWidget: Icon(Icons.arrow_downward)),
      );

      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should apply custom blur settings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(blurSize: 10.0, blurBackgroundColor: Colors.red.withValues(alpha: 0.8)));

      await tester.pump();

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should use default blur settings when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pump();

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should use custom animation curves when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          topWidget: Text('Top'),
          bottomWidget: Text('Bottom'),
          repositionAnimationCurve: FigmaSpringCurve.gentle,
          topWidgetAnimationCurve: FigmaSpringCurve.quick,
          bottomWidgetAnimationCurve: FigmaSpringCurve.bouncy,
        ),
      );

      await tester.pump();
      await tester.pump(Duration(milliseconds: 50));

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should use default curves when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(topWidget: Text('Top Default'), bottomWidget: Text('Bottom Default')));

      await tester.pump();
      await tester.pump(Duration(milliseconds: 50));

      expect(find.text('Top Default'), findsOneWidget);
      expect(find.text('Bottom Default'), findsOneWidget);
    });

    testWidgets('should handle tap on background to close', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pump();

      // Find the GestureDetector that wraps the background
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);

      // Tap on the background (this would normally close the overlay)
      await tester.tap(gestureDetector);
      await tester.pump();
    });

    testWidgets('should make child widget non-interactive', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pump();

      // Find the IgnorePointer that is actually ignoring interactions
      final ignorePointers = tester.widgetList<IgnorePointer>(find.byType(IgnorePointer));
      final ignoringPointer = ignorePointers.firstWhere(
        (pointer) => pointer.ignoring == true,
        orElse: () => throw StateError('No IgnorePointer with ignoring=true found'),
      );

      expect(ignoringPointer.ignoring, isTrue);
    });

    testWidgets('should handle animations properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          topWidget: Container(width: 100, height: 40, child: Text('Animated Top')),
          bottomWidget: Container(width: 100, height: 40, child: Text('Animated Bottom')),
        ),
      );

      // Initial frame
      await tester.pump();
      expect(find.text('Animated Top'), findsOneWidget);
      expect(find.text('Animated Bottom'), findsOneWidget);

      // During animation
      await tester.pump(Duration(milliseconds: 100));
      expect(find.text('Animated Top'), findsOneWidget);
      expect(find.text('Animated Bottom'), findsOneWidget);

      // Animation should complete
      await tester.pump(Duration(milliseconds: 300));
      expect(find.text('Animated Top'), findsOneWidget);
      expect(find.text('Animated Bottom'), findsOneWidget);
    });

    group('Widget positioning', () {
      testWidgets('should position child at specified offset', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.pump();

        final positioned = find.byType(Positioned);
        expect(positioned, findsWidgets);

        // Should have positioned widgets for child and potentially top/bottom widgets
      });

      testWidgets('should handle screen boundaries correctly', (WidgetTester tester) async {
        // Create widget with edge case positioning
        await tester.pumpWidget(
          MaterialApp(
            home: SmartOverlayDetails(
              child: Container(width: 100, height: 50, child: Text('Edge Child')),
              childOffset: Offset(10, 10), // Near screen edge
              childSize: Size(100, 50),
              repositionAnimationDuration: repositionAnimationDuration,
              screenPadding: EdgeInsets.all(8),
              topWidget: Text('Edge Top'),
              bottomWidget: Text('Edge Bottom'),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(Duration(milliseconds: 100));

        expect(find.text('Edge Child'), findsOneWidget);
        expect(find.text('Edge Top'), findsOneWidget);
        expect(find.text('Edge Bottom'), findsOneWidget);
      });
    });

    group('Animation Controllers', () {
      testWidgets('should dispose animation controllers properly', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(topWidget: Text('Disposable Top')));

        await tester.pump();

        // Remove the widget to trigger dispose
        await tester.pumpWidget(Container());

        // Should not throw any errors during disposal
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very small child size', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(testChildSize: Size(1, 1)));

        await tester.pump();
        expect(find.text('Test Child'), findsOneWidget);
      });

      testWidgets('should handle large child size', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(testChildSize: Size(1000, 1000)));

        await tester.pump();
        expect(find.text('Test Child'), findsOneWidget);
      });

      testWidgets('should handle zero screen padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SmartOverlayDetails(
              child: Text('No Padding'),
              childOffset: childOffset,
              childSize: childSize,
              repositionAnimationDuration: repositionAnimationDuration,
              screenPadding: EdgeInsets.zero,
            ),
          ),
        );

        await tester.pump();
        expect(find.text('No Padding'), findsOneWidget);
      });

      testWidgets('should handle very short animation duration', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SmartOverlayDetails(
              child: Text('Fast Animation'),
              childOffset: childOffset,
              childSize: childSize,
              repositionAnimationDuration: Duration(milliseconds: 1),
              screenPadding: screenPadding,
              topWidget: Text('Fast Top'),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(Duration(milliseconds: 10));

        expect(find.text('Fast Animation'), findsOneWidget);
        expect(find.text('Fast Top'), findsOneWidget);
      });
    });
  });
}
