import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/src/models/driver_animation_model.dart';
import 'package:animated_car_marker/src/models/rotation_target.dart';

/// Unit tests for DriverAnimationModel class
/// 
/// Tests the driver animation state model including initialization,
/// state management, and debug functionality.
void main() {
  group('DriverAnimationModel Unit Tests', () {
    group('Constructor and Initialization', () {
      test('should create model with required driver ID', () {
        const driverId = 'test_driver_1';
        
        final model = DriverAnimationModel(driverId: driverId);
        
        expect(model.driverId, equals(driverId));
        expect(model.currentAngle, equals(0.0));
        expect(model.targetAngle, equals(0.0));
        expect(model.shouldAnimate, isFalse);
        expect(model.animationSpeed, equals(0.18));
        expect(model.smoothingFactor, equals(0.25));
        expect(model.animationTicks, equals(0));
        expect(model.targetChangeInterval, equals(100));
        expect(model.lastTargetChange, equals(0));
        expect(model.currentTargetType, equals(RotationTarget.random));
      });

      test('should create model with custom parameters', () {
        const driverId = 'test_driver_2';
        const currentAngle = 45.5;
        const targetAngle = 90.25;
        const shouldAnimate = true;
        const animationSpeed = 0.35;
        const smoothingFactor = 0.4;
        const animationTicks = 50;
        const targetChangeInterval = 150;
        const lastTargetChange = 25;
        const currentTargetType = RotationTarget.maximum;
        
        final model = DriverAnimationModel(
          driverId: driverId,
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          shouldAnimate: shouldAnimate,
          animationSpeed: animationSpeed,
          smoothingFactor: smoothingFactor,
          animationTicks: animationTicks,
          targetChangeInterval: targetChangeInterval,
          lastTargetChange: lastTargetChange,
          currentTargetType: currentTargetType,
        );
        
        expect(model.driverId, equals(driverId));
        expect(model.currentAngle, equals(currentAngle));
        expect(model.targetAngle, equals(targetAngle));
        expect(model.shouldAnimate, equals(shouldAnimate));
        expect(model.animationSpeed, equals(animationSpeed));
        expect(model.smoothingFactor, equals(smoothingFactor));
        expect(model.animationTicks, equals(animationTicks));
        expect(model.targetChangeInterval, equals(targetChangeInterval));
        expect(model.lastTargetChange, equals(lastTargetChange));
        expect(model.currentTargetType, equals(currentTargetType));
      });

      test('should handle empty driver ID', () {
        const driverId = '';
        
        final model = DriverAnimationModel(driverId: driverId);
        
        expect(model.driverId, equals(driverId));
        expect(model, isA<DriverAnimationModel>());
      });

      test('should handle special characters in driver ID', () {
        const driverId = 'driver_123-abc@test.com';
        
        final model = DriverAnimationModel(driverId: driverId);
        
        expect(model.driverId, equals(driverId));
      });
    });

    group('Target Change Detection', () {
      test('should detect when target should change', () {
        final model = DriverAnimationModel(
          driverId: 'test_driver',
          targetChangeInterval: 10,
          lastTargetChange: 0,
          animationTicks: 0,
        );
        
        // Initially should not change
        expect(model.shouldChangeTarget(), isFalse);
        
        // Advance ticks beyond interval
        model.animationTicks = 11;
        expect(model.shouldChangeTarget(), isTrue);
      });

      test('should not change target before interval', () {
        final model = DriverAnimationModel(
          driverId: 'test_driver',
          targetChangeInterval: 20,
          lastTargetChange: 5,
          animationTicks: 15,
        );
        
        // 15 - 5 = 10, which is less than 20
        expect(model.shouldChangeTarget(), isFalse);
      });

      test('should change target exactly at interval', () {
        final model = DriverAnimationModel(
          driverId: 'test_driver',
          targetChangeInterval: 10,
          lastTargetChange: 5,
          animationTicks: 15,
        );
        
        // 15 - 5 = 10, which equals the interval
        expect(model.shouldChangeTarget(), isTrue);
      });

      test('should handle zero interval', () {
        final model = DriverAnimationModel(
          driverId: 'test_driver',
          targetChangeInterval: 0,
          lastTargetChange: 0,
          animationTicks: 1,
        );
        
        // Should always be true with zero interval
        expect(model.shouldChangeTarget(), isTrue);
      });

      test('should handle negative values gracefully', () {
        final model = DriverAnimationModel(
          driverId: 'test_driver',
          targetChangeInterval: 10,
          lastTargetChange: 20, // Greater than current ticks
          animationTicks: 15,
        );
        
        // Should handle negative difference
        expect(model.shouldChangeTarget(), isFalse);
      });
    });

    group('Target Change Marking', () {
      test('should mark target as changed', () {
        final model = DriverAnimationModel(
          driverId: 'test_driver',
          animationTicks: 25,
          lastTargetChange: 10,
        );
        
        model.markTargetChanged();
        
        expect(model.lastTargetChange, equals(25));
      });

      test('should update last target change to current ticks', () {
        final model = DriverAnimationModel(
          driverId: 'test_driver',
          animationTicks: 100,
          lastTargetChange: 0,
        );
        
        model.markTargetChanged();
        
        expect(model.lastTargetChange, equals(100));
      });

      test('should work with zero ticks', () {
        final model = DriverAnimationModel(
          driverId: 'test_driver',
          animationTicks: 0,
          lastTargetChange: 50,
        );
        
        model.markTargetChanged();
        
        expect(model.lastTargetChange, equals(0));
      });
    });

    group('Debug Information', () {
      test('should provide comprehensive debug map', () {
        final model = DriverAnimationModel(
          driverId: 'debug_test_driver',
          currentAngle: 45.123,
          targetAngle: 90.456,
          shouldAnimate: true,
          animationSpeed: 0.234,
          smoothingFactor: 0.345,
          animationTicks: 150,
          targetChangeInterval: 75,
          lastTargetChange: 100,
          currentTargetType: RotationTarget.maximum,
        );
        
        final debugMap = model.toDebugMap();
        
        expect(debugMap['driverId'], equals('debug_test_driver'));
        expect(debugMap['currentAngle'], equals('45.12'));
        expect(debugMap['targetAngle'], equals('90.46'));
        expect(debugMap['shouldAnimate'], isTrue);
        expect(debugMap['speed'], equals('0.234'));
        expect(debugMap['smoothness'], equals('0.345'));
        expect(debugMap['ticks'], equals(150));
        expect(debugMap['pattern'], equals(1));
        expect(debugMap['targetType'], equals('maximum'));
        expect(debugMap['ticksUntilChange'], equals(25)); // 75 - (150 - 100)
      });

      test('should format angles with two decimal places', () {
        final model = DriverAnimationModel(
          driverId: 'format_test',
          currentAngle: 45.123456,
          targetAngle: 90.987654,
        );
        
        final debugMap = model.toDebugMap();
        
        expect(debugMap['currentAngle'], equals('45.12'));
        expect(debugMap['targetAngle'], equals('90.99'));
      });

      test('should handle zero and negative angles in debug', () {
        final model = DriverAnimationModel(
          driverId: 'zero_test',
          currentAngle: 0.0,
          targetAngle: -45.678,
        );
        
        final debugMap = model.toDebugMap();
        
        expect(debugMap['currentAngle'], equals('0.00'));
        expect(debugMap['targetAngle'], equals('-45.68'));
      });

      test('should include all rotation target types in debug', () {
        for (final targetType in RotationTarget.values) {
          final model = DriverAnimationModel(
            driverId: 'target_test',
            currentTargetType: targetType,
          );
          
          final debugMap = model.toDebugMap();
          
          expect(debugMap['targetType'], equals(targetType.name));
        }
      });

      test('should handle very large numbers in debug', () {
        final model = DriverAnimationModel(
          driverId: 'large_test',
          currentAngle: 999999.123,
          targetAngle: -999999.987,
          animationTicks: 999999,
        );
        
        final debugMap = model.toDebugMap();
        
        expect(debugMap['currentAngle'], equals('999999.12'));
        expect(debugMap['targetAngle'], equals('-999999.99'));
        expect(debugMap['ticks'], equals(999999));
      });
    });

    group('State Validation', () {
      test('should maintain state consistency', () {
        final model = DriverAnimationModel(
          driverId: 'consistency_test',
          currentAngle: 45.0,
          targetAngle: 90.0,
          shouldAnimate: true,
          animationSpeed: 0.25,
        );
        
        // State should remain consistent
        expect(model.driverId, equals('consistency_test'));
        expect(model.currentAngle, equals(45.0));
        expect(model.targetAngle, equals(90.0));
        expect(model.shouldAnimate, isTrue);
        expect(model.animationSpeed, equals(0.25));
        
        // Modify state
        model.currentAngle = 50.0;
        model.shouldAnimate = false;
        
        // Changes should be reflected
        expect(model.currentAngle, equals(50.0));
        expect(model.shouldAnimate, isFalse);
        
        // Other properties should remain unchanged
        expect(model.driverId, equals('consistency_test'));
        expect(model.targetAngle, equals(90.0));
        expect(model.animationSpeed, equals(0.25));
      });

      test('should handle extreme angle values', () {
        final model = DriverAnimationModel(
          driverId: 'extreme_test',
          currentAngle: double.maxFinite,
          targetAngle: -double.maxFinite,
        );
        
        expect(model.currentAngle, equals(double.maxFinite));
        expect(model.targetAngle, equals(-double.maxFinite));
        
        // Debug should handle extreme values
        final debugMap = model.toDebugMap();
        expect(debugMap['currentAngle'], isA<String>());
        expect(debugMap['targetAngle'], isA<String>());
      });

      test('should handle NaN and infinity values', () {
        final model = DriverAnimationModel(
          driverId: 'nan_test',
          currentAngle: double.nan,
          targetAngle: double.infinity,
        );
        
        expect(model.currentAngle.isNaN, isTrue);
        expect(model.targetAngle.isInfinite, isTrue);
        
        // Debug should handle special values
        final debugMap = model.toDebugMap();
        expect(debugMap['currentAngle'], isA<String>());
        expect(debugMap['targetAngle'], isA<String>());
      });
    });

    group('Property Boundaries', () {
      test('should handle minimum values', () {
        final model = DriverAnimationModel(
          driverId: 'min_test',
          currentAngle: -180.0,
          targetAngle: -180.0,
          animationSpeed: 0.0,
          smoothingFactor: 0.0,
          animationTicks: 0,
          targetChangeInterval: 0,
          lastTargetChange: 0,
        );
        
        expect(model.currentAngle, equals(-180.0));
        expect(model.targetAngle, equals(-180.0));
        expect(model.animationSpeed, equals(0.0));
        expect(model.smoothingFactor, equals(0.0));
        expect(model.animationTicks, equals(0));
        expect(model.targetChangeInterval, equals(0));
        expect(model.lastTargetChange, equals(0));
      });

      test('should handle maximum reasonable values', () {
        final model = DriverAnimationModel(
          driverId: 'max_test',
          currentAngle: 180.0,
          targetAngle: 180.0,
          animationSpeed: 1.0,
          smoothingFactor: 1.0,
          animationTicks: 999999,
          targetChangeInterval: 999999,
          lastTargetChange: 999999,
        );
        
        expect(model.currentAngle, equals(180.0));
        expect(model.targetAngle, equals(180.0));
        expect(model.animationSpeed, equals(1.0));
        expect(model.smoothingFactor, equals(1.0));
        expect(model.animationTicks, equals(999999));
        expect(model.targetChangeInterval, equals(999999));
        expect(model.lastTargetChange, equals(999999));
      });
    });

    group('Equality and Comparison', () {
      test('should create identical models with same parameters', () {
        const driverId = 'identical_test';
        const currentAngle = 45.0;
        const targetAngle = 90.0;
        
        final model1 = DriverAnimationModel(
          driverId: driverId,
          currentAngle: currentAngle,
          targetAngle: targetAngle,
        );
        
        final model2 = DriverAnimationModel(
          driverId: driverId,
          currentAngle: currentAngle,
          targetAngle: targetAngle,
        );
        
        // Properties should be identical
        expect(model1.driverId, equals(model2.driverId));
        expect(model1.currentAngle, equals(model2.currentAngle));
        expect(model1.targetAngle, equals(model2.targetAngle));
        expect(model1.shouldAnimate, equals(model2.shouldAnimate));
        expect(model1.animationSpeed, equals(model2.animationSpeed));
      });

      test('should differentiate models with different driver IDs', () {
        final model1 = DriverAnimationModel(driverId: 'driver_1');
        final model2 = DriverAnimationModel(driverId: 'driver_2');
        
        expect(model1.driverId, isNot(equals(model2.driverId)));
      });
    });

    group('Performance Tests', () {
      test('should create models efficiently', () {
        const iterations = 1000;
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < iterations; i++) {
          final model = DriverAnimationModel(
            driverId: 'perf_test_$i',
            currentAngle: i.toDouble(),
            targetAngle: (i * 2).toDouble(),
            shouldAnimate: i % 2 == 0,
          );
          
          // Access properties to ensure they're properly initialized
          expect(model.driverId, isNotNull);
          expect(model.currentAngle, isA<double>());
        }
        
        stopwatch.stop();
        
        // Should create models quickly (less than 100ms for 1000 models)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should generate debug maps efficiently', () {
        const iterations = 1000;
        final models = List.generate(
          iterations,
          (i) => DriverAnimationModel(
            driverId: 'debug_perf_$i',
            currentAngle: i.toDouble(),
            targetAngle: (i * 2).toDouble(),
          ),
        );
        
        final stopwatch = Stopwatch()..start();
        
        for (final model in models) {
          final debugMap = model.toDebugMap();
          expect(debugMap, isA<Map<String, dynamic>>());
        }
        
        stopwatch.stop();
        
        // Should generate debug maps quickly (less than 100ms for 1000 maps)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle target change detection efficiently', () {
        const iterations = 10000;
        final model = DriverAnimationModel(
          driverId: 'change_perf_test',
          targetChangeInterval: 100,
        );
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < iterations; i++) {
          model.animationTicks = i;
          final shouldChange = model.shouldChangeTarget();
          expect(shouldChange, isA<bool>());
          
          if (shouldChange) {
            model.markTargetChanged();
          }
        }
        
        stopwatch.stop();
        
        // Should perform calculations quickly (less than 100ms for 10000 checks)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}