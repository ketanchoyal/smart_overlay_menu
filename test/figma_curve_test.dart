import 'package:flutter_test/flutter_test.dart';
import 'package:smart_overlay_menu/src/widgets/figma_curve.dart';

void main() {
  group('FigmaSpringCurve', () {
    test('should create curve with valid parameters', () {
      final curve = FigmaSpringCurve(stiffness: 100, damping: 15, mass: 1, initialVelocity: 0.5);

      expect(curve, isNotNull);
      expect(curve, isA<FigmaSpringCurve>());
    });

    test('should handle under-damped case correctly', () {
      final curve = FigmaSpringCurve(
        stiffness: 100,
        damping: 10, // Low damping for under-damped
        mass: 1,
        initialVelocity: 0.5,
      );

      // Test boundary values - spring curves can exceed 1.0 which is normal
      expect(curve.transform(0.0), equals(0.0));
      expect(curve.transform(1.0), equals(1.0));

      // Test intermediate values - spring may overshoot
      final midValue = curve.transform(0.5);
      expect(midValue, greaterThan(0.0));
    });

    test('should handle critically damped case correctly', () {
      final curve = FigmaSpringCurve(
        stiffness: 100,
        damping: 20, // High damping for critically damped
        mass: 1,
        initialVelocity: 0.5,
      );

      // Test boundary values
      expect(curve.transform(0.0), equals(0.0));
      expect(curve.transform(1.0), equals(1.0));

      // Test that values exist
      final t1 = curve.transform(0.3);
      final t2 = curve.transform(0.7);
      expect(t1, isNotNull);
      expect(t2, isNotNull);
    });

    test('should handle zero initial velocity', () {
      final curve = FigmaSpringCurve(stiffness: 100, damping: 15, mass: 1, initialVelocity: 0.0);

      expect(curve.transform(0.0), equals(0.0));
      expect(curve.transform(1.0), equals(1.0));
    });

    test('should handle negative initial velocity', () {
      final curve = FigmaSpringCurve(stiffness: 100, damping: 15, mass: 1, initialVelocity: -0.5);

      expect(curve.transform(0.0), equals(0.0));
      expect(curve.transform(1.0), equals(1.0));
    });

    test('should produce valid transformation values', () {
      final curve = FigmaSpringCurve(stiffness: 100, damping: 15, mass: 1, initialVelocity: 0.5);

      for (double t = 0.0; t <= 1.0; t += 0.1) {
        final transformValue = curve.transform(t);
        expect(transformValue, isNotNull);
        expect(transformValue, isA<double>());
        expect(transformValue.isFinite, isTrue);
      }
    });

    group('Predefined curves', () {
      test('gentle curve should be accessible', () {
        expect(FigmaSpringCurve.gentle, isNotNull);
        expect(FigmaSpringCurve.gentle, isA<FigmaSpringCurve>());

        // Test that it works
        expect(FigmaSpringCurve.gentle.transform(0.0), equals(0.0));
        expect(FigmaSpringCurve.gentle.transform(1.0), equals(1.0));
      });

      test('quick curve should be accessible', () {
        expect(FigmaSpringCurve.quick, isNotNull);
        expect(FigmaSpringCurve.quick, isA<FigmaSpringCurve>());

        // Test that it works
        expect(FigmaSpringCurve.quick.transform(0.0), equals(0.0));
        expect(FigmaSpringCurve.quick.transform(1.0), equals(1.0));
      });

      test('bouncy curve should be accessible', () {
        expect(FigmaSpringCurve.bouncy, isNotNull);
        expect(FigmaSpringCurve.bouncy, isA<FigmaSpringCurve>());

        // Test that it works
        expect(FigmaSpringCurve.bouncy.transform(0.0), equals(0.0));
        expect(FigmaSpringCurve.bouncy.transform(1.0), equals(1.0));
      });

      test('slow curve should be accessible', () {
        expect(FigmaSpringCurve.slow, isNotNull);
        expect(FigmaSpringCurve.slow, isA<FigmaSpringCurve>());

        // Test that it works
        expect(FigmaSpringCurve.slow.transform(0.0), equals(0.0));
        expect(FigmaSpringCurve.slow.transform(1.0), equals(1.0));
      });

      test('predefined curves should produce valid values', () {
        final t = 0.5;

        final gentleValue = FigmaSpringCurve.gentle.transform(t);
        final quickValue = FigmaSpringCurve.quick.transform(t);
        final bouncyValue = FigmaSpringCurve.bouncy.transform(t);
        final slowValue = FigmaSpringCurve.slow.transform(t);

        // They should all be valid finite numbers
        expect(gentleValue.isFinite, isTrue);
        expect(quickValue.isFinite, isTrue);
        expect(bouncyValue.isFinite, isTrue);
        expect(slowValue.isFinite, isTrue);
      });
    });

    group('Edge cases', () {
      test('should handle very small stiffness', () {
        final curve = FigmaSpringCurve(stiffness: 0.1, damping: 1, mass: 1, initialVelocity: 0.5);

        expect(curve.transform(0.0), equals(0.0));
        expect(curve.transform(1.0), equals(1.0));
      });

      test('should handle very large stiffness', () {
        final curve = FigmaSpringCurve(stiffness: 10000, damping: 100, mass: 1, initialVelocity: 0.5);

        expect(curve.transform(0.0), equals(0.0));
        expect(curve.transform(1.0), equals(1.0));
      });

      test('should handle very small mass', () {
        final curve = FigmaSpringCurve(stiffness: 100, damping: 15, mass: 0.1, initialVelocity: 0.5);

        expect(curve.transform(0.0), equals(0.0));
        expect(curve.transform(1.0), equals(1.0));
      });

      test('should handle large mass', () {
        final curve = FigmaSpringCurve(stiffness: 100, damping: 15, mass: 10, initialVelocity: 0.5);

        expect(curve.transform(0.0), equals(0.0));
        expect(curve.transform(1.0), equals(1.0));
      });
    });

    group('Mathematical properties', () {
      test('should satisfy curve boundary conditions', () {
        final curve = FigmaSpringCurve(stiffness: 100, damping: 15, mass: 1, initialVelocity: 0.5);

        // Curve should start at 0 and end at 1
        expect(curve.transform(0.0), equals(0.0));
        expect(curve.transform(1.0), equals(1.0));
      });

      test('should produce continuous values', () {
        final curve = FigmaSpringCurve(stiffness: 100, damping: 15, mass: 1, initialVelocity: 0.5);

        // Sample multiple points and ensure they are finite
        final samples = <double>[];
        for (int i = 0; i <= 10; i++) {
          final value = curve.transform(i / 10.0);
          samples.add(value);
          expect(value.isFinite, isTrue);
        }

        // First and last should be 0 and 1
        expect(samples.first, equals(0.0));
        expect(samples.last, equals(1.0));
      });
    });
  });
}
