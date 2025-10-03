import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/src/utils/animation_calculator.dart';
import 'package:animated_car_marker/src/models/rotation_target.dart';

/// Unit tests for AnimationCalculator utility class
/// 
/// Tests all mathematical calculations and utility methods used
/// for smooth car marker animations.
void main() {
  group('AnimationCalculator Unit Tests', () {
    group('Smoothed Angle Calculation', () {
      test('should calculate smoothed angle correctly', () {
        const currentAngle = 0.0;
        const targetAngle = 90.0;
        const smoothingFactor = 0.25;
        
        final result = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: smoothingFactor,
        );
        
        // Should be 25% of the way from current to target
        expect(result, closeTo(22.5, 0.1));
      });

      test('should handle wrap-around angles correctly', () {
        const currentAngle = 350.0;
        const targetAngle = 10.0;
        const smoothingFactor = 0.5;
        
        final result = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: smoothingFactor,
        );
        
        // Should take the short path (20° clockwise)
        // 350 + (20 * 0.5) = 360 (which wraps to 0)
        expect(result, closeTo(360.0, 0.1));
      });

      test('should handle zero smoothing factor', () {
        const currentAngle = 45.0;
        const targetAngle = 135.0;
        const smoothingFactor = 0.0;
        
        final result = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: smoothingFactor,
        );
        
        // Should remain at current angle
        expect(result, equals(currentAngle));
      });

      test('should handle full smoothing factor', () {
        const currentAngle = 45.0;
        const targetAngle = 135.0;
        const smoothingFactor = 1.0;
        
        final result = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: smoothingFactor,
        );
        
        // Should reach target angle
        expect(result, equals(targetAngle));
      });

      test('should handle negative angles', () {
        const currentAngle = -45.0;
        const targetAngle = -90.0;
        const smoothingFactor = 0.5;
        
        final result = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: smoothingFactor,
        );
        
        // Should be halfway between -45 and -90
        expect(result, closeTo(-67.5, 0.1));
      });
    });

    group('Angle Difference Calculation', () {
      test('should calculate simple angle difference', () {
        final result = AnimationCalculator.calculateAngleDifference(
          currentAngle: 10.0,
          targetAngle: 50.0,
        );
        
        expect(result, closeTo(40.0, 0.1));
      });

      test('should calculate shortest path for wrap-around', () {
        final result = AnimationCalculator.calculateAngleDifference(
          currentAngle: 350.0,
          targetAngle: 10.0,
        );
        
        // Should go +20° instead of -340°
        expect(result, closeTo(20.0, 0.1));
      });

      test('should calculate shortest path for reverse wrap-around', () {
        final result = AnimationCalculator.calculateAngleDifference(
          currentAngle: 10.0,
          targetAngle: 350.0,
        );
        
        // Should go -20° instead of +340°
        expect(result, closeTo(-20.0, 0.1));
      });

      test('should handle 180-degree difference correctly', () {
        final result1 = AnimationCalculator.calculateAngleDifference(
          currentAngle: 0.0,
          targetAngle: 180.0,
        );
        
        final result2 = AnimationCalculator.calculateAngleDifference(
          currentAngle: 180.0,
          targetAngle: 0.0,
        );
        
        expect(result1, closeTo(180.0, 0.1));
        expect(result2, closeTo(-180.0, 0.1));
      });

      test('should handle same angles', () {
        final result = AnimationCalculator.calculateAngleDifference(
          currentAngle: 45.0,
          targetAngle: 45.0,
        );
        
        expect(result, closeTo(0.0, 0.1));
      });
    });

    group('Angle Normalization', () {
      test('should normalize positive angles over 360', () {
        expect(AnimationCalculator.normalizeAngle(450.0), closeTo(90.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(720.0), closeTo(0.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(370.0), closeTo(10.0, 0.1));
      });

      test('should normalize negative angles', () {
        expect(AnimationCalculator.normalizeAngle(-30.0), closeTo(330.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(-90.0), closeTo(270.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(-370.0), closeTo(350.0, 0.1));
      });

      test('should handle angles already in range', () {
        expect(AnimationCalculator.normalizeAngle(0.0), closeTo(0.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(180.0), closeTo(180.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(359.9), closeTo(359.9, 0.1));
      });

      test('should handle very large angles', () {
        expect(AnimationCalculator.normalizeAngle(1080.0), closeTo(0.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(-1080.0), closeTo(0.0, 0.1));
      });
    });

    group('Random Target Generation', () {
      late math.Random fixedRandom;

      setUp(() {
        // Use fixed seed for reproducible tests
        fixedRandom = math.Random(42);
      });

      test('should generate maximum rotation targets', () {
        const maxAngle = 180.0;
        
        final target = AnimationCalculator.generateRandomTarget(
          targetType: RotationTarget.maximum,
          maxAngle: maxAngle,
          random: fixedRandom,
        );
        
        // Should be close to maximum angle (±180°)
        expect(target.abs(), greaterThan(maxAngle * 0.8));
        expect(target.abs(), lessThanOrEqualTo(maxAngle));
      });

      test('should generate minimum rotation targets', () {
        const maxAngle = 180.0;
        
        final target = AnimationCalculator.generateRandomTarget(
          targetType: RotationTarget.minimum,
          maxAngle: maxAngle,
          random: fixedRandom,
        );
        
        // Should be small rotation (around 10% of max)
        expect(target.abs(), lessThan(maxAngle * 0.3));
      });

      test('should generate center rotation targets', () {
        const maxAngle = 180.0;
        
        final target = AnimationCalculator.generateRandomTarget(
          targetType: RotationTarget.center,
          maxAngle: maxAngle,
          random: fixedRandom,
        );
        
        // Should be close to center (0°) with small random offset
        expect(target.abs(), lessThan(15.0)); // Small offset allowed
      });

      test('should generate random rotation targets', () {
        const maxAngle = 180.0;
        
        final target = AnimationCalculator.generateRandomTarget(
          targetType: RotationTarget.random,
          maxAngle: maxAngle,
          random: fixedRandom,
        );
        
        // Should be within 70% of max range plus random offset
        expect(target.abs(), lessThanOrEqualTo(maxAngle));
      });

      test('should clamp targets to maximum angle', () {
        const maxAngle = 90.0;
        
        for (final targetType in RotationTarget.values) {
          final target = AnimationCalculator.generateRandomTarget(
            targetType: targetType,
            maxAngle: maxAngle,
            random: fixedRandom,
          );
          
          expect(target, greaterThanOrEqualTo(-maxAngle));
          expect(target, lessThanOrEqualTo(maxAngle));
        }
      });

      test('should generate different values with different random seeds', () {
        const maxAngle = 180.0;
        final random1 = math.Random(1);
        final random2 = math.Random(2);
        
        final target1 = AnimationCalculator.generateRandomTarget(
          targetType: RotationTarget.random,
          maxAngle: maxAngle,
          random: random1,
        );
        
        final target2 = AnimationCalculator.generateRandomTarget(
          targetType: RotationTarget.random,
          maxAngle: maxAngle,
          random: random2,
        );
        
        // Should be different (very unlikely to be the same)
        expect(target1, isNot(closeTo(target2, 0.1)));
      });
    });

    group('Animation Speed Calculation', () {
      late math.Random fixedRandom;

      setUp(() {
        fixedRandom = math.Random(42);
      });

      test('should calculate slow speed correctly', () {
        const minSpeed = 0.08;
        const mediumSpeed = 0.18;
        const maxSpeed = 0.35;
        
        final speed = AnimationCalculator.calculateAnimationSpeed(
          speedType: 0,
          minSpeed: minSpeed,
          mediumSpeed: mediumSpeed,
          maxSpeed: maxSpeed,
          random: fixedRandom,
        );
        
        expect(speed, greaterThanOrEqualTo(minSpeed));
        expect(speed, lessThanOrEqualTo(minSpeed + 0.05));
      });

      test('should calculate medium speed correctly', () {
        const minSpeed = 0.08;
        const mediumSpeed = 0.18;
        const maxSpeed = 0.35;
        
        final speed = AnimationCalculator.calculateAnimationSpeed(
          speedType: 1,
          minSpeed: minSpeed,
          mediumSpeed: mediumSpeed,
          maxSpeed: maxSpeed,
          random: fixedRandom,
        );
        
        expect(speed, greaterThanOrEqualTo(mediumSpeed));
        expect(speed, lessThanOrEqualTo(mediumSpeed + 0.08));
      });

      test('should calculate fast speed correctly', () {
        const minSpeed = 0.08;
        const mediumSpeed = 0.18;
        const maxSpeed = 0.35;
        
        final speed = AnimationCalculator.calculateAnimationSpeed(
          speedType: 2,
          minSpeed: minSpeed,
          mediumSpeed: mediumSpeed,
          maxSpeed: maxSpeed,
          random: fixedRandom,
        );
        
        expect(speed, greaterThanOrEqualTo(maxSpeed));
        expect(speed, lessThanOrEqualTo(maxSpeed + 0.15));
      });

      test('should default to medium speed for invalid type', () {
        const minSpeed = 0.08;
        const mediumSpeed = 0.18;
        const maxSpeed = 0.35;
        
        final speed = AnimationCalculator.calculateAnimationSpeed(
          speedType: 99, // Invalid type
          minSpeed: minSpeed,
          mediumSpeed: mediumSpeed,
          maxSpeed: maxSpeed,
          random: fixedRandom,
        );
        
        expect(speed, equals(mediumSpeed));
      });
    });

    group('Smoothing Factor Calculation', () {
      test('should calculate smoothing factor based on speed', () {
        const baseSmoothingFactor = 0.25;
        const animationSpeed = 0.35;
        
        final smoothing = AnimationCalculator.calculateSmoothingFactor(
          animationSpeed: animationSpeed,
          baseSmoothingFactor: baseSmoothingFactor,
        );
        
        // Should be higher than base due to speed
        expect(smoothing, greaterThan(baseSmoothingFactor));
        expect(smoothing, lessThanOrEqualTo(0.45)); // Default max
      });

      test('should clamp smoothing factor to specified range', () {
        const baseSmoothingFactor = 0.25;
        const animationSpeed = 1.0; // Very high speed
        const minSmoothingFactor = 0.2;
        const maxSmoothingFactor = 0.4;
        
        final smoothing = AnimationCalculator.calculateSmoothingFactor(
          animationSpeed: animationSpeed,
          baseSmoothingFactor: baseSmoothingFactor,
          minSmoothingFactor: minSmoothingFactor,
          maxSmoothingFactor: maxSmoothingFactor,
        );
        
        expect(smoothing, greaterThanOrEqualTo(minSmoothingFactor));
        expect(smoothing, lessThanOrEqualTo(maxSmoothingFactor));
      });

      test('should handle zero animation speed', () {
        const baseSmoothingFactor = 0.25;
        const animationSpeed = 0.0;
        
        final smoothing = AnimationCalculator.calculateSmoothingFactor(
          animationSpeed: animationSpeed,
          baseSmoothingFactor: baseSmoothingFactor,
        );
        
        expect(smoothing, equals(baseSmoothingFactor));
      });
    });

    group('Angle Equality Comparison', () {
      test('should detect equal angles within tolerance', () {
        expect(
          AnimationCalculator.areAnglesEqual(
            angle1: 45.0,
            angle2: 45.5,
            tolerance: 1.0,
          ),
          isTrue,
        );
      });

      test('should detect unequal angles outside tolerance', () {
        expect(
          AnimationCalculator.areAnglesEqual(
            angle1: 45.0,
            angle2: 47.0,
            tolerance: 1.0,
          ),
          isFalse,
        );
      });

      test('should handle wrap-around angle comparison', () {
        expect(
          AnimationCalculator.areAnglesEqual(
            angle1: 359.5,
            angle2: 0.5,
            tolerance: 1.0,
          ),
          isTrue,
        );
      });

      test('should use default tolerance correctly', () {
        expect(
          AnimationCalculator.areAnglesEqual(
            angle1: 45.0,
            angle2: 45.5,
          ),
          isTrue,
        );
        
        expect(
          AnimationCalculator.areAnglesEqual(
            angle1: 45.0,
            angle2: 47.0,
          ),
          isFalse,
        );
      });
    });

    group('Angle Conversion', () {
      test('should convert degrees to radians correctly', () {
        expect(
          AnimationCalculator.degreesToRadians(0.0),
          closeTo(0.0, 0.001),
        );
        expect(
          AnimationCalculator.degreesToRadians(90.0),
          closeTo(math.pi / 2, 0.001),
        );
        expect(
          AnimationCalculator.degreesToRadians(180.0),
          closeTo(math.pi, 0.001),
        );
        expect(
          AnimationCalculator.degreesToRadians(360.0),
          closeTo(2 * math.pi, 0.001),
        );
      });

      test('should convert radians to degrees correctly', () {
        expect(
          AnimationCalculator.radiansToDegrees(0.0),
          closeTo(0.0, 0.001),
        );
        expect(
          AnimationCalculator.radiansToDegrees(math.pi / 2),
          closeTo(90.0, 0.001),
        );
        expect(
          AnimationCalculator.radiansToDegrees(math.pi),
          closeTo(180.0, 0.001),
        );
        expect(
          AnimationCalculator.radiansToDegrees(2 * math.pi),
          closeTo(360.0, 0.001),
        );
      });

      test('should handle negative angle conversions', () {
        expect(
          AnimationCalculator.degreesToRadians(-90.0),
          closeTo(-math.pi / 2, 0.001),
        );
        expect(
          AnimationCalculator.radiansToDegrees(-math.pi),
          closeTo(-180.0, 0.001),
        );
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle very small smoothing factors', () {
        const currentAngle = 0.0;
        const targetAngle = 90.0;
        const smoothingFactor = 0.001;
        
        final result = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: smoothingFactor,
        );
        
        // Should move very slightly towards target
        expect(result, greaterThan(currentAngle));
        expect(result, lessThan(1.0));
      });

      test('should handle very large smoothing factors', () {
        const currentAngle = 0.0;
        const targetAngle = 90.0;
        const smoothingFactor = 10.0;
        
        final result = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: smoothingFactor,
        );
        
        // Should overshoot the target
        expect(result, greaterThan(targetAngle));
      });

      test('should handle extreme angle values', () {
        expect(
          AnimationCalculator.normalizeAngle(double.maxFinite),
          isA<double>(),
        );
        expect(
          AnimationCalculator.normalizeAngle(-double.maxFinite),
          isA<double>(),
        );
      });

      test('should handle zero tolerance in angle comparison', () {
        expect(
          AnimationCalculator.areAnglesEqual(
            angle1: 45.0,
            angle2: 45.0,
            tolerance: 0.0,
          ),
          isTrue,
        );
        
        expect(
          AnimationCalculator.areAnglesEqual(
            angle1: 45.0,
            angle2: 45.1,
            tolerance: 0.0,
          ),
          isFalse,
        );
      });
    });

    group('Performance Tests', () {
      test('should perform calculations efficiently', () {
        const iterations = 1000;
        final random = math.Random(42);
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < iterations; i++) {
          final currentAngle = random.nextDouble() * 360;
          final targetAngle = random.nextDouble() * 360;
          
          AnimationCalculator.calculateSmoothedAngle(
            currentAngle: currentAngle,
            targetAngle: targetAngle,
            smoothingFactor: 0.25,
          );
          
          AnimationCalculator.calculateAngleDifference(
            currentAngle: currentAngle,
            targetAngle: targetAngle,
          );
          
          AnimationCalculator.normalizeAngle(currentAngle + targetAngle);
        }
        
        stopwatch.stop();
        
        // Should complete quickly (less than 100ms for 1000 iterations)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}