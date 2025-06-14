import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_overlay_menu/src/widgets/overlay_widget_builders.dart';

void main() {
  group('OverlayWidgetBuilders', () {
    late GlobalKey testKey;
    late Animation<double> mockRepositionAnimation;
    late Animation<double> mockFadeAnimation;

    setUp(() {
      testKey = GlobalKey();
    });

    Widget createTestApp(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [child],
          ),
        ),
      );
    }

    testWidgets('should build top widget correctly', (WidgetTester tester) async {
      final mockAnimationController = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: tester,
      );

      mockRepositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(mockAnimationController);
      mockFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(mockAnimationController);

      final topWidget = OverlayWidgetBuilders.buildTopWidget(
        widgetKey: testKey,
        widget: Text('Top Widget'),
        padding: EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        childSize: Size(100, 50),
        leftPosition: 50,
        topPosition: 100,
        repositionAnimation: mockRepositionAnimation,
        fadeAnimation: mockFadeAnimation,
        isClosing: false,
        animationCurve: Curves.easeInOut,
      );

      await tester.pumpWidget(createTestApp(topWidget));

      expect(find.text('Top Widget'), findsOneWidget);
      expect(find.byType(Positioned), findsWidgets);
      expect(find.byType(AnimatedBuilder), findsWidgets);

      mockAnimationController.dispose();
    });

    testWidgets('should build bottom widget correctly', (WidgetTester tester) async {
      final mockAnimationController = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: tester,
      );

      mockRepositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(mockAnimationController);
      mockFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(mockAnimationController);

      final bottomWidget = OverlayWidgetBuilders.buildBottomWidget(
        widgetKey: testKey,
        widget: Text('Bottom Widget'),
        padding: EdgeInsets.all(12),
        alignment: Alignment.centerRight,
        childSize: Size(100, 50),
        leftPosition: 75,
        topPosition: 200,
        repositionAnimation: mockRepositionAnimation,
        fadeAnimation: mockFadeAnimation,
        isClosing: false,
        animationCurve: Curves.bounceIn,
      );

      await tester.pumpWidget(createTestApp(bottomWidget));

      expect(find.text('Bottom Widget'), findsOneWidget);
      expect(find.byType(Positioned), findsWidgets);
      expect(find.byType(AnimatedBuilder), findsWidgets);

      mockAnimationController.dispose();
    });

    testWidgets('should handle null padding correctly', (WidgetTester tester) async {
      final mockAnimationController = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: tester,
      );

      mockRepositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(mockAnimationController);
      mockFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(mockAnimationController);

      final widget = OverlayWidgetBuilders.buildTopWidget(
        widgetKey: testKey,
        widget: Icon(Icons.star),
        padding: null,
        alignment: null,
        childSize: Size(100, 50),
        leftPosition: 50,
        topPosition: 100,
        repositionAnimation: mockRepositionAnimation,
        fadeAnimation: mockFadeAnimation,
        isClosing: false,
        animationCurve: null,
      );

      await tester.pumpWidget(createTestApp(widget));

      expect(find.byIcon(Icons.star), findsOneWidget);

      mockAnimationController.dispose();
    });

    testWidgets('should handle closing state correctly', (WidgetTester tester) async {
      final mockAnimationController = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: tester,
      );

      mockRepositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(mockAnimationController);
      mockFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(mockAnimationController);

      // Set animation to closing state
      mockAnimationController.value = 0.5;

      final widget = OverlayWidgetBuilders.buildBottomWidget(
        widgetKey: testKey,
        widget: Container(
          width: 100,
          height: 50,
          color: Colors.blue,
          child: Text('Closing Widget'),
        ),
        padding: EdgeInsets.all(8),
        alignment: Alignment.center,
        childSize: Size(100, 50),
        leftPosition: 50,
        topPosition: 100,
        repositionAnimation: mockRepositionAnimation,
        fadeAnimation: mockFadeAnimation,
        isClosing: true,
        animationCurve: Curves.easeOut,
      );

      await tester.pumpWidget(createTestApp(widget));

      expect(find.text('Closing Widget'), findsOneWidget);

      mockAnimationController.dispose();
    });

    testWidgets('should animate correctly during repositioning', (WidgetTester tester) async {
      final mockAnimationController = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: tester,
      );

      mockRepositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(mockAnimationController);
      mockFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(mockAnimationController);

      final widget = OverlayWidgetBuilders.buildTopWidget(
        widgetKey: testKey,
        widget: Text('Animating Widget'),
        padding: EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        childSize: Size(100, 50),
        leftPosition: 50,
        topPosition: 100,
        repositionAnimation: mockRepositionAnimation,
        fadeAnimation: mockFadeAnimation,
        isClosing: false,
        animationCurve: Curves.elasticOut,
      );

      await tester.pumpWidget(createTestApp(widget));

      // Start animation
      mockAnimationController.forward();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 50));

      expect(find.text('Animating Widget'), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();

      expect(find.text('Animating Widget'), findsOneWidget);

      mockAnimationController.dispose();
    });

    testWidgets('should handle different alignment values', (WidgetTester tester) async {
      final mockAnimationController = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: tester,
      );

      mockRepositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(mockAnimationController);
      mockFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(mockAnimationController);

      final alignments = [
        Alignment.centerLeft,
        Alignment.center,
        Alignment.centerRight,
        Alignment.topLeft,
        Alignment.bottomRight,
      ];

      for (final alignment in alignments) {
        final widget = OverlayWidgetBuilders.buildBottomWidget(
          widgetKey: GlobalKey(), // Use unique key for each test
          widget: Text('Aligned Widget'),
          padding: EdgeInsets.all(4),
          alignment: alignment,
          childSize: Size(100, 50),
          leftPosition: 50,
          topPosition: 100,
          repositionAnimation: mockRepositionAnimation,
          fadeAnimation: mockFadeAnimation,
          isClosing: false,
          animationCurve: Curves.linear,
        );

        await tester.pumpWidget(createTestApp(widget));
        expect(find.text('Aligned Widget'), findsOneWidget);
      }

      mockAnimationController.dispose();
    });

    testWidgets('should handle complex child widgets', (WidgetTester tester) async {
      final mockAnimationController = AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: tester,
      );

      mockRepositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(mockAnimationController);
      mockFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(mockAnimationController);

      final complexChild = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: Colors.red),
          Text('Like'),
          ElevatedButton(
            onPressed: () {},
            child: Text('Action'),
          ),
        ],
      );

      final widget = OverlayWidgetBuilders.buildTopWidget(
        widgetKey: testKey,
        widget: complexChild,
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        childSize: Size(200, 100),
        leftPosition: 100,
        topPosition: 50,
        repositionAnimation: mockRepositionAnimation,
        fadeAnimation: mockFadeAnimation,
        isClosing: false,
        animationCurve: Curves.fastOutSlowIn,
      );

      await tester.pumpWidget(createTestApp(widget));

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Like'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      mockAnimationController.dispose();
    });
  });

  group('OverlayPositionCalculator', () {
    test('should calculate left position for different alignments', () {
      const childSize = Size(100, 50);
      const currentChildX = 150.0;

      // Left alignment
      final leftPos = OverlayPositionCalculator.calculateLeftPosition(
        currentChildX: currentChildX,
        childSize: childSize,
        alignment: Alignment.centerLeft,
      );
      expect(leftPos, equals(currentChildX));

      // Center alignment
      final centerPos = OverlayPositionCalculator.calculateLeftPosition(
        currentChildX: currentChildX,
        childSize: childSize,
        alignment: Alignment.center,
      );
      expect(centerPos, equals(currentChildX + (childSize.width / 2)));

      // Right alignment
      final rightPos = OverlayPositionCalculator.calculateLeftPosition(
        currentChildX: currentChildX,
        childSize: childSize,
        alignment: Alignment.centerRight,
      );
      expect(rightPos, equals(currentChildX + childSize.width));
    });

    test('should handle null alignment and childSize', () {
      const currentChildX = 100.0;

      final pos1 = OverlayPositionCalculator.calculateLeftPosition(
        currentChildX: currentChildX,
        childSize: null,
        alignment: Alignment.center,
      );
      expect(pos1, equals(currentChildX));

      final pos2 = OverlayPositionCalculator.calculateLeftPosition(
        currentChildX: currentChildX,
        childSize: Size(100, 50),
        alignment: null,
      );
      expect(pos2, equals(currentChildX));
    });

    test('should calculate top widget position correctly', () {
      const currentChildY = 200.0;
      const topWidgetHeight = 80.0;
      const screenTop = 50.0;
      const childHeight = 60.0;
      const availableHeight = 700.0;

      // Normal case
      final normalPos = OverlayPositionCalculator.calculateTopWidgetPosition(
        currentChildY: currentChildY,
        topWidgetHeight: topWidgetHeight,
        screenTop: screenTop,
        childHeight: childHeight,
        availableHeight: availableHeight,
      );
      expect(normalPos, equals(currentChildY - topWidgetHeight));

      // Child larger than screen case
      final largeChildPos = OverlayPositionCalculator.calculateTopWidgetPosition(
        currentChildY: 100.0, // Close to top
        topWidgetHeight: topWidgetHeight,
        screenTop: screenTop,
        childHeight: 800.0, // Larger than available height
        availableHeight: availableHeight,
      );
      expect(largeChildPos, equals(screenTop));
    });

    test('should calculate bottom widget position correctly', () {
      const currentChildY = 200.0;
      const childHeight = 60.0;
      const bottomWidgetHeight = 80.0;
      const screenBottom = 750.0;
      const availableHeight = 700.0;

      // Normal case
      final normalPos = OverlayPositionCalculator.calculateBottomWidgetPosition(
        currentChildY: currentChildY,
        childHeight: childHeight,
        bottomWidgetHeight: bottomWidgetHeight,
        screenBottom: screenBottom,
        availableHeight: availableHeight,
      );
      expect(normalPos, equals(currentChildY + childHeight));

      // Child larger than screen case
      final largeChildPos = OverlayPositionCalculator.calculateBottomWidgetPosition(
        currentChildY: 100.0,
        childHeight: 800.0, // Larger than available height
        bottomWidgetHeight: bottomWidgetHeight,
        screenBottom: screenBottom,
        availableHeight: availableHeight,
      );
      expect(largeChildPos, equals(screenBottom - bottomWidgetHeight));
    });
  });
}
