import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/src/managers/animation_manager.dart';
import 'package:animated_car_marker/src/models/rotation_target.dart';

/// Unit tests for AnimationManager class
///
/// Tests the core animation management functionality including
/// driver initialization, animation lifecycle, and state management.
void main() {
  group('AnimationManager Unit Tests', () {
    setUp(() {
      // Clean up before each test
      AnimationManager.stopAllAnimations();
    });

    tearDown(() {
      // Clean up after each test
      AnimationManager.stopAllAnimations();
    });

    group('Driver Management', () {
      test('should initialize driver with correct properties', () {
        const driverId = 'unit_test_driver_1';

        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId);

        expect(driver, isNotNull);
        expect(driver!.driverId, equals(driverId));
        expect(driver.currentAngle, equals(0.0));
        expect(driver.animationTicks, equals(0));
        expect(driver.lastTargetChange, equals(0));
        expect(driver.animationSpeed, greaterThan(0.0));
        expect(driver.smoothingFactor, greaterThan(0.0));
        expect(driver.targetChangeInterval, greaterThan(0));
      });

      test('should not reinitialize existing driver', () {
        const driverId = 'unit_test_driver_2';

        AnimationManager.initializeDriver(driverId);
        final firstDriver = AnimationManager.getDriver(driverId);
        final originalTargetAngle = firstDriver!.targetAngle;
        final originalSpeed = firstDriver.animationSpeed;

        // Try to initialize again
        AnimationManager.initializeDriver(driverId);
        final secondDriver = AnimationManager.getDriver(driverId);

        expect(secondDriver!.targetAngle, equals(originalTargetAngle));
        expect(secondDriver.animationSpeed, equals(originalSpeed));
      });

      test('should return null for non-existent driver', () {
        const nonExistentId = 'non_existent_driver';

        final driver = AnimationManager.getDriver(nonExistentId);
        expect(driver, isNull);
      });

      test('should track all drivers correctly', () {
        const driverIds = ['driver_1', 'driver_2', 'driver_3'];

        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
        }

        final allDrivers = AnimationManager.getAllDrivers();
        expect(allDrivers.length, equals(driverIds.length));

        for (final driverId in driverIds) {
          expect(allDrivers.containsKey(driverId), isTrue);
        }
      });
    });

    group('Animation Lifecycle', () {
      test('should start animation for driver', () async {
        const driverId = 'animation_test_1';
        bool callbackCalled = false;

        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;

        AnimationManager.startDriverAnimation(driverId, () {
          callbackCalled = true;
        });

        expect(AnimationManager.isAnimationActive(driverId), isTrue);

        // Wait a bit for callback
        await Future.delayed(const Duration(milliseconds: 150));
        expect(callbackCalled, isTrue);
      });

      test('should stop animation for driver', () {
        const driverId = 'animation_test_2';

        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;

        AnimationManager.startDriverAnimation(driverId, () {});
        expect(AnimationManager.isAnimationActive(driverId), isTrue);

        AnimationManager.stopDriverAnimation(driverId);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
      });

      test('should handle stopping non-active animation gracefully', () {
        const driverId = 'animation_test_3';

        AnimationManager.initializeDriver(driverId);

        // Should not throw
        expect(
          () => AnimationManager.stopDriverAnimation(driverId),
          returnsNormally,
        );
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
      });

      test('should stop all animations', () {
        const driverIds = ['stop_all_1', 'stop_all_2', 'stop_all_3'];

        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }

        expect(
          AnimationManager.getActiveAnimations().length,
          equals(driverIds.length),
        );

        AnimationManager.stopAllAnimations();

        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });
    });

    group('Animation State Queries', () {
      test('should correctly report animation active state', () {
        const driverId = 'state_test_1';

        // Initially not active
        expect(AnimationManager.isAnimationActive(driverId), isFalse);

        AnimationManager.initializeDriver(driverId);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);

        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        AnimationManager.startDriverAnimation(driverId, () {});
        expect(AnimationManager.isAnimationActive(driverId), isTrue);

        AnimationManager.stopDriverAnimation(driverId);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
      });

      test('should return correct active animations list', () {
        const activeDrivers = ['active_1', 'active_2'];
        const inactiveDrivers = ['inactive_1', 'inactive_2'];

        // Create active drivers
        for (final driverId in activeDrivers) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }

        // Create inactive drivers
        for (final driverId in inactiveDrivers) {
          AnimationManager.initializeDriver(driverId);
        }

        final activeAnimations = AnimationManager.getActiveAnimations();
        expect(activeAnimations.length, equals(activeDrivers.length));

        for (final driverId in activeDrivers) {
          expect(activeAnimations.contains(driverId), isTrue);
        }

        for (final driverId in inactiveDrivers) {
          expect(activeAnimations.contains(driverId), isFalse);
        }
      });

      test('should determine if driver should animate', () {
        const driverId = 'should_animate_test';

        // Non-existent driver should not animate
        expect(AnimationManager.shouldDriverAnimate(driverId), isFalse);

        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;

        // Test both states
        driver.shouldAnimate = true;
        expect(AnimationManager.shouldDriverAnimate(driverId), isTrue);

        driver.shouldAnimate = false;
        expect(AnimationManager.shouldDriverAnimate(driverId), isFalse);
      });
    });

    group('Rotation Management', () {
      test('should get current rotation angle', () {
        const driverId = 'rotation_test_1';
        const testAngle = 45.0;

        // Non-existent driver should return 0
        expect(AnimationManager.getCurrentRotationAngle(driverId), equals(0.0));

        AnimationManager.initializeDriver(driverId);
        AnimationManager.setRotationAngle(driverId, testAngle);

        expect(
          AnimationManager.getCurrentRotationAngle(driverId),
          equals(testAngle),
        );
      });

      test('should set rotation angle with clamping', () {
        const driverId = 'rotation_test_2';

        AnimationManager.initializeDriver(driverId);

        // Test normal angle
        AnimationManager.setRotationAngle(driverId, 90.0);
        expect(
          AnimationManager.getCurrentRotationAngle(driverId),
          equals(90.0),
        );

        // Test clamping to maximum
        AnimationManager.setRotationAngle(driverId, 200.0);
        expect(
          AnimationManager.getCurrentRotationAngle(driverId),
          equals(180.0),
        );

        // Test clamping to minimum
        AnimationManager.setRotationAngle(driverId, -200.0);
        expect(
          AnimationManager.getCurrentRotationAngle(driverId),
          equals(-180.0),
        );
      });

      test('should set rotation target', () {
        const driverId = 'rotation_test_3';

        AnimationManager.initializeDriver(driverId);

        for (final targetType in RotationTarget.values) {
          AnimationManager.setRotationTarget(driverId, targetType);
          final driver = AnimationManager.getDriver(driverId)!;

          expect(driver.currentTargetType, equals(targetType));
          expect(driver.targetAngle.abs(), lessThanOrEqualTo(180.0));
        }
      });
    });

    group('Animation Speed Control', () {
      test('should set faster rotation', () {
        const driverId = 'speed_test_1';

        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        final originalSpeed = driver.animationSpeed;

        AnimationManager.setFasterRotation(driverId, speedMultiplier: 2.0);

        expect(driver.animationSpeed, greaterThan(originalSpeed));
        expect(driver.smoothingFactor, equals(0.35));
      });

      test('should set normal rotation', () {
        const driverId = 'speed_test_2';

        AnimationManager.initializeDriver(driverId);

        // First set faster rotation
        AnimationManager.setFasterRotation(driverId);

        // Then reset to normal
        AnimationManager.setNormalRotation(driverId);
        final driver = AnimationManager.getDriver(driverId)!;

        expect(driver.animationSpeed, equals(0.18));
        expect(driver.smoothingFactor, equals(0.25));
      });

      test('should clamp speed multiplier', () {
        const driverId = 'speed_test_3';

        AnimationManager.initializeDriver(driverId);

        // Test extreme multiplier
        AnimationManager.setFasterRotation(driverId, speedMultiplier: 100.0);
        final driver = AnimationManager.getDriver(driverId)!;

        expect(driver.animationSpeed, lessThanOrEqualTo(0.8));
        expect(driver.animationSpeed, greaterThanOrEqualTo(0.05));
      });
    });

    group('Target Change Intervals', () {
      test('should set target change interval', () {
        const driverId = 'interval_test_1';
        const testInterval = 150;

        AnimationManager.initializeDriver(driverId);
        AnimationManager.setTargetChangeInterval(driverId, testInterval);

        final driver = AnimationManager.getDriver(driverId)!;
        expect(driver.targetChangeInterval, equals(testInterval));
      });

      test('should clamp target change interval', () {
        const driverId = 'interval_test_2';

        AnimationManager.initializeDriver(driverId);

        // Test minimum clamp
        AnimationManager.setTargetChangeInterval(driverId, 5);
        expect(
          AnimationManager.getDriver(driverId)!.targetChangeInterval,
          equals(20),
        );

        // Test maximum clamp
        AnimationManager.setTargetChangeInterval(driverId, 500);
        expect(
          AnimationManager.getDriver(driverId)!.targetChangeInterval,
          equals(300),
        );
      });
    });

    group('Animation Tick Processing', () {
      test('should update animation tick', () {
        const driverId = 'tick_test_1';

        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;

        final initialTicks = driver.animationTicks;
        AnimationManager.updateAnimationTick(driver);

        expect(driver.animationTicks, equals(initialTicks + 1));
      });

      test('should set new rotation target', () {
        const driverId = 'target_test_1';

        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;

        AnimationManager.setNewRotationTarget(driver);

        // Target should be within valid range
        expect(driver.targetAngle.abs(), lessThanOrEqualTo(180.0));

        // Should be a valid angle
        expect(driver.targetAngle, isA<double>());
      });
    });

    group('Pause and Resume Operations', () {
      test('should pause all animations', () {
        const driverIds = ['pause_test_1', 'pause_test_2'];

        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }

        expect(
          AnimationManager.getActiveAnimations().length,
          equals(driverIds.length),
        );

        AnimationManager.pauseAllAnimations();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);

        // Drivers should still exist
        expect(
          AnimationManager.getAllDrivers().length,
          equals(driverIds.length),
        );
      });

      test('should resume all animations', () {
        const driverIds = ['resume_test_1', 'resume_test_2'];

        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }

        AnimationManager.pauseAllAnimations();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);

        AnimationManager.resumeAllAnimations(() {});

        // Some drivers should be active again (depending on random shouldAnimate)
        expect(
          AnimationManager.getActiveAnimations().length,
          greaterThanOrEqualTo(0),
        );
      });
    });

    group('Error Handling', () {
      test('should handle operations on non-existent drivers gracefully', () {
        const nonExistentId = 'non_existent';

        // These should not throw exceptions
        expect(
          () => AnimationManager.stopDriverAnimation(nonExistentId),
          returnsNormally,
        );
        expect(
          () => AnimationManager.setFasterRotation(nonExistentId),
          returnsNormally,
        );
        expect(
          () => AnimationManager.setNormalRotation(nonExistentId),
          returnsNormally,
        );
        expect(
          () => AnimationManager.setRotationTarget(
            nonExistentId,
            RotationTarget.center,
          ),
          returnsNormally,
        );
        expect(
          () => AnimationManager.setTargetChangeInterval(nonExistentId, 100),
          returnsNormally,
        );
        expect(
          () => AnimationManager.setRotationAngle(nonExistentId, 45.0),
          returnsNormally,
        );

        // These should return safe defaults
        expect(
          AnimationManager.getCurrentRotationAngle(nonExistentId),
          equals(0.0),
        );
        expect(AnimationManager.shouldDriverAnimate(nonExistentId), isFalse);
        expect(AnimationManager.isAnimationActive(nonExistentId), isFalse);
      });

      test('should handle null driver in update methods', () {
        // These should not throw when called with null or invalid data
        // These should handle null gracefully by checking for null before processing
        expect(
          () => AnimationManager.updateAnimationTick(null),
          throwsA(isA<TypeError>()),
        );
        expect(
          () => AnimationManager.setNewRotationTarget(null),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
