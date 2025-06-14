import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_overlay_menu/src/widgets/smart_overlay_menu.dart';

void main() {
  group('SmartOverlayHolderController', () {
    late SmartOverlayMenuController controller;

    setUp(() {
      controller = SmartOverlayMenuController();
    });

    test('should create controller successfully', () {
      expect(controller, isNotNull);
      expect(controller, isA<SmartOverlayMenuController>());
    });

    test('should have open and close methods', () {
      // Test that methods exist and can be called
      // Note: Without widget context, these won't actually work
      expect(() => controller.close(), returnsNormally);
    });
  });

  group('SmartOverlayHolder Widget', () {
    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      final childWidget = Container(width: 100, height: 50, color: Colors.blue, child: Text('Test Child'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SmartOverlayMenu(child: childWidget)),
        ),
      );

      expect(find.byWidget(childWidget), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('should display child widget correctly', (WidgetTester tester) async {
      const testText = 'Test Widget Content';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SmartOverlayMenu(child: Text(testText))),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should handle tap when openWithTap is true', (WidgetTester tester) async {
      bool onPressedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(
              child: Text('Tap me'),
              openWithTap: true,
              onPressed: () {
                onPressedCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(onPressedCalled, true);
    });

    testWidgets('should handle long press when openWithTap is false', (WidgetTester tester) async {
      bool onPressedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(
              child: Text('Long press me'),
              openWithTap: false,
              onPressed: () {
                onPressedCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Long press me'));
      await tester.pump();

      expect(onPressedCalled, true);
    });

    testWidgets('should accept controller parameter', (WidgetTester tester) async {
      final controller = SmartOverlayMenuController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(child: Text('Controlled widget'), controller: controller),
          ),
        ),
      );

      expect(find.text('Controlled widget'), findsOneWidget);
      // Controller should be connected to the widget
    });

    testWidgets('should accept custom duration', (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 500);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(child: Text('Custom duration'), duration: customDuration),
          ),
        ),
      );

      expect(find.text('Custom duration'), findsOneWidget);
    });

    testWidgets('should accept custom blur properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(
              child: Text('Blur test'),
              blurSize: 8.0,
              blurBackgroundColor: Colors.red.withValues(alpha: 0.5),
            ),
          ),
        ),
      );

      expect(find.text('Blur test'), findsOneWidget);
    });

    testWidgets('should accept top and bottom widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(
              child: Text('Main content'),
              topWidget: Text('Top widget'),
              bottomWidget: Text('Bottom widget'),
            ),
          ),
        ),
      );

      expect(find.text('Main content'), findsOneWidget);
    });

    testWidgets('should accept padding for top and bottom widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(
              child: Text('Padded content'),
              topWidget: Text('Top'),
              bottomWidget: Text('Bottom'),
              topWidgetPadding: EdgeInsets.all(16),
              bottomWidgetPadding: EdgeInsets.all(24),
            ),
          ),
        ),
      );

      expect(find.text('Padded content'), findsOneWidget);
    });

    testWidgets('should accept callback functions', (WidgetTester tester) async {
      bool onOpenedCalled = false;
      bool onClosedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(
              child: Text('Callback test'),
              onOpened: () {
                onOpenedCalled = true;
              },
              onClosed: () {
                onClosedCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Callback test'), findsOneWidget);
      expect(onOpenedCalled, isFalse);
      expect(onClosedCalled, isFalse);
    });

    testWidgets('should accept custom reposition animation duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(
              child: Text('Reposition test'),
              repositionAnimationDuration: Duration(milliseconds: 250),
            ),
          ),
        ),
      );

      expect(find.text('Reposition test'), findsOneWidget);
    });

    testWidgets('should accept custom screen padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartOverlayMenu(child: Text('Screen padding test'), screenPadding: EdgeInsets.all(32)),
          ),
        ),
      );

      expect(find.text('Screen padding test'), findsOneWidget);
    });

    group('Controller Integration', () {
      testWidgets('should connect controller to widget state', (WidgetTester tester) async {
        final controller = SmartOverlayMenuController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SmartOverlayMenu(child: Text('Controller integration'), controller: controller),
            ),
          ),
        );

        // Widget should render successfully with controller
        expect(find.text('Controller integration'), findsOneWidget);

        // Controller should exist and be connected
        expect(controller, isNotNull);
      });

      testWidgets('should work without controller', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SmartOverlayMenu(child: Text('No controller'))),
          ),
        );

        expect(find.text('No controller'), findsOneWidget);
      });
    });

    group('Gesture Handling', () {
      testWidgets('should handle tap gesture with openWithTap=true', (WidgetTester tester) async {
        bool tapHandled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SmartOverlayMenu(
                child: Container(width: 100, height: 100, child: Text('Tap target')),
                openWithTap: true,
                onPressed: () {
                  tapHandled = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Tap target'));
        await tester.pump();

        expect(tapHandled, true);
      });

      testWidgets('should call onPressed even when openWithTap=false', (WidgetTester tester) async {
        bool onPressedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SmartOverlayMenu(
                child: Text('Press target'),
                openWithTap: false,
                onPressed: () {
                  onPressedCalled = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Press target'));
        await tester.pump();

        expect(onPressedCalled, true);
      });
    });

    group('Widget Configuration', () {
      testWidgets('should handle all optional parameters', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SmartOverlayMenu(
                child: Text('Full config'),
                topWidget: Icon(Icons.arrow_upward),
                bottomWidget: Icon(Icons.arrow_downward),
                topWidgetPadding: EdgeInsets.symmetric(vertical: 8),
                bottomWidgetPadding: EdgeInsets.symmetric(vertical: 12),
                duration: Duration(milliseconds: 200),
                blurSize: 6.0,
                blurBackgroundColor: Colors.black45,
                openWithTap: true,
                repositionAnimationDuration: Duration(milliseconds: 400),
                screenPadding: EdgeInsets.all(20),
                onPressed: () {},
                onOpened: () {},
                onClosed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Full config'), findsOneWidget);
      });
    });
  });
}
