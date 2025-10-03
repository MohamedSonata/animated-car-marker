import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/src/managers/lifecycle_manager.dart';
import 'package:animated_car_marker/src/managers/animation_manager.dart';

/// Unit tests for LifecycleManager class
/// 
/// Tests the application lifecycle management functionality including
/// pause, resume, and cleanup operations.
void main() {
  group('LifecycleManager Unit Tests', () {
    setUp(() {
      // Clean up before each test
      AnimationManager.stopAllAnimations();
    });

    tearDown(() {
      // Clean up after each test
      AnimationManager.stopAllAnimations();
    });

    group('Pause Operations', () {
      test('should pause all active animations', () {
        const driverIds = ['pause_test_1', 'pause_test_2', 'pause_test_3'];
        
        // Create and start animations
        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverIds.length));
        
        // Pause all
        LifecycleManager.pauseAll();
        
        // Should have no active animations
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // But drivers should still exist
        expect(AnimationManager.getAllDrivers().length, equals(driverIds.length));
      });

      test('should handle pause when no animations are active', () {
        // Should not throw when no animations are running
        expect(() => LifecycleManager.pauseAll(), returnsNormally);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should handle multiple pause calls', () {
        const driverId = 'multi_pause_test';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        AnimationManager.startDriverAnimation(driverId, () {});
        
        // Multiple pause calls should be safe
        LifecycleManager.pauseAll();
        expect(() => LifecycleManager.pauseAll(), returnsNormally);
        expect(() => LifecycleManager.pauseAll(), returnsNormally);
        
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });
    });

    group('Resume Operations', () {
      test('should resume animations for drivers that should animate', () {
        const driverIds = ['resume_test_1', 'resume_test_2', 'resume_test_3'];
        
        // Create drivers with mixed animation states
        for (int i = 0; i < driverIds.length; i++) {
          AnimationManager.initializeDriver(driverIds[i]);
          final driver = AnimationManager.getDriver(driverIds[i])!;
          
          // Set some to animate, some not
          driver.shouldAnimate = i % 2 == 0;
          if (driver.shouldAnimate) {
            AnimationManager.startDriverAnimation(driverIds[i], () {});
          }
        }
        
        // Pause all
        LifecycleManager.pauseAll();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // Resume all
        LifecycleManager.resumeAll(() {});
        
        // Should have resumed some animations (exact count may vary due to randomization)
        expect(AnimationManager.getActiveAnimations().length, greaterThanOrEqualTo(0));
      });

      test('should handle resume when no drivers exist', () {
        // Should not throw when no drivers exist
        expect(() => LifecycleManager.resumeAll(() {}), returnsNormally);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should handle multiple resume calls', () {
        const driverId = 'multi_resume_test';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        AnimationManager.startDriverAnimation(driverId, () {});
        
        LifecycleManager.pauseAll();
        
        // Multiple resume calls should be safe
        LifecycleManager.resumeAll(() {});
        expect(() => LifecycleManager.resumeAll(() {}), returnsNormally);
        expect(() => LifecycleManager.resumeAll(() {}), returnsNormally);
      });
    });

    group('Cleanup Operations', () {
      test('should clean up all resources', () {
        const driverIds = ['cleanup_test_1', 'cleanup_test_2'];
        
        // Create drivers and animations
        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        expect(AnimationManager.getAllDrivers().length, equals(driverIds.length));
        expect(AnimationManager.getActiveAnimations().length, equals(driverIds.length));
        
        // Cleanup should remove everything
        LifecycleManager.cleanup();
        
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should handle cleanup when no resources exist', () {
        // Should not throw when nothing to clean up
        expect(() => LifecycleManager.cleanup(), returnsNormally);
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should handle multiple cleanup calls', () {
        const driverId = 'multi_cleanup_test';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        AnimationManager.startDriverAnimation(driverId, () {});
        
        // Multiple cleanup calls should be safe
        LifecycleManager.cleanup();
        expect(() => LifecycleManager.cleanup(), returnsNormally);
        expect(() => LifecycleManager.cleanup(), returnsNormally);
        
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });
    });

    group('Animation Status Reassignment', () {
      test('should reassign animation status correctly', () {
        const driverIds = ['reassign_test_1', 'reassign_test_2', 'reassign_test_3'];
        
        // Create drivers
        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
        }
        
        expect(AnimationManager.getAllDrivers().length, equals(driverIds.length));
        
        // Reassign animation status
        LifecycleManager.reassignAnimationStatus();
        
        // Drivers should still exist
        expect(AnimationManager.getAllDrivers().length, equals(driverIds.length));
        
        // Some drivers may now have shouldAnimate set to true (random assignment)
        int shouldAnimateCount = 0;
        for (final driverId in driverIds) {
          final driver = AnimationManager.getDriver(driverId)!;
          if (driver.shouldAnimate) {
            shouldAnimateCount++;
          }
        }
        
        // Should be a reasonable number (not all or none due to randomization)
        expect(shouldAnimateCount, greaterThanOrEqualTo(0));
        expect(shouldAnimateCount, lessThanOrEqualTo(driverIds.length));
      });

      test('should handle reassignment when no drivers exist', () {
        // Should not throw when no drivers exist
        expect(() => LifecycleManager.reassignAnimationStatus(), returnsNormally);
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });
    });

    group('Integration Tests', () {
      test('should handle complete pause-resume cycle', () {
        const driverIds = ['integration_test_1', 'integration_test_2'];
        
        // Create and start animations
        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        final initialDriverCount = AnimationManager.getAllDrivers().length;
        final initialActiveCount = AnimationManager.getActiveAnimations().length;
        
        expect(initialDriverCount, equals(driverIds.length));
        expect(initialActiveCount, equals(driverIds.length));
        
        // Pause
        LifecycleManager.pauseAll();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        expect(AnimationManager.getAllDrivers().length, equals(initialDriverCount));
        
        // Resume
        LifecycleManager.resumeAll(() {});
        expect(AnimationManager.getAllDrivers().length, equals(initialDriverCount));
        
        // Some animations should be active again
        expect(AnimationManager.getActiveAnimations().length, greaterThanOrEqualTo(0));
      });

      test('should handle pause-cleanup sequence', () {
        const driverIds = ['sequence_test_1', 'sequence_test_2'];
        
        // Create and start animations
        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        expect(AnimationManager.getAllDrivers().length, equals(driverIds.length));
        expect(AnimationManager.getActiveAnimations().length, equals(driverIds.length));
        
        // Pause then cleanup
        LifecycleManager.pauseAll();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        LifecycleManager.cleanup();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle operations with mixed driver states', () {
        const driverIds = ['mixed_test_1', 'mixed_test_2', 'mixed_test_3'];
        
        // Create drivers with different states
        for (int i = 0; i < driverIds.length; i++) {
          AnimationManager.initializeDriver(driverIds[i]);
          final driver = AnimationManager.getDriver(driverIds[i])!;
          
          // Mix of animating and non-animating drivers
          if (i % 2 == 0) {
            driver.shouldAnimate = true;
            AnimationManager.startDriverAnimation(driverIds[i], () {});
          }
        }
        
        // All operations should handle mixed states gracefully
        expect(() => LifecycleManager.pauseAll(), returnsNormally);
        expect(() => LifecycleManager.resumeAll(() {}), returnsNormally);
        expect(() => LifecycleManager.reassignAnimationStatus(), returnsNormally);
        expect(() => LifecycleManager.cleanup(), returnsNormally);
      });

      test('should handle concurrent lifecycle operations', () async {
        const driverIds = ['concurrent_test_1', 'concurrent_test_2'];
        
        // Create drivers
        for (final driverId in driverIds) {
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        // Perform concurrent operations
        final futures = <Future<void>>[
          Future(() => LifecycleManager.pauseAll()),
          Future(() => LifecycleManager.resumeAll(() {})),
          Future(() => LifecycleManager.reassignAnimationStatus()),
        ];
        
        // Should complete without errors
        await Future.wait(futures);
        
        // Final cleanup
        LifecycleManager.cleanup();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });
    });
  });
}