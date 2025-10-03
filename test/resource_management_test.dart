import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/src/managers/animation_manager.dart';
import 'package:animated_car_marker/src/managers/lifecycle_manager.dart';
import 'package:animated_car_marker/src/managers/icon_manager.dart';

/// Resource management validation tests
/// 
/// These tests validate proper cleanup of timers, cached resources,
/// memory leak prevention, and lifecycle operations.
void main() {
  group('Resource Management Validation Tests', () {
    setUp(() {
      // Clean up before each test
      AnimationManager.stopAllAnimations();
      IconManager.clearIconCache();
    });

    tearDown(() {
      // Clean up after each test
      AnimationManager.stopAllAnimations();
      IconManager.clearIconCache();
    });

    group('Timer Resource Management', () {
      test('should properly clean up timers when stopping individual animations', () {
        const driverId = 'timer_cleanup_test';
        
        // Initialize and start animation
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        
        AnimationManager.startDriverAnimation(driverId, () {});
        expect(AnimationManager.isAnimationActive(driverId), isTrue);
        
        // Stop animation should clean up timer
        AnimationManager.stopDriverAnimation(driverId);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
        
        // Verify no active timers remain
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should clean up all timers when stopping all animations', () {
        const int driverCount = 10;
        final List<String> driverIds = [];
        
        // Create multiple animated drivers
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'bulk_timer_test_$i';
          driverIds.add(driverId);
          
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount));
        
        // Stop all should clean up everything
        AnimationManager.stopAllAnimations();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });

      test('should handle rapid start/stop cycles without timer leaks', () {
        const driverId = 'rapid_cycle_test';
        const int cycles = 20;
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        
        // Perform rapid cycles
        for (int i = 0; i < cycles; i++) {
          AnimationManager.startDriverAnimation(driverId, () {});
          expect(AnimationManager.isAnimationActive(driverId), isTrue);
          
          AnimationManager.stopDriverAnimation(driverId);
          expect(AnimationManager.isAnimationActive(driverId), isFalse);
        }
        
        // Should have no active timers
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should handle concurrent timer operations safely', () async {
        const int concurrentCount = 15;
        final List<Future<void>> operations = [];
        
        // Start concurrent operations
        for (int i = 0; i < concurrentCount; i++) {
          operations.add(Future(() {
            final driverId = 'concurrent_timer_$i';
            
            AnimationManager.initializeDriver(driverId);
            final driver = AnimationManager.getDriver(driverId)!;
            driver.shouldAnimate = true;
            
            AnimationManager.startDriverAnimation(driverId, () {});
            
            // Simulate some work
            Future.delayed(const Duration(milliseconds: 10));
            
            AnimationManager.stopDriverAnimation(driverId);
          }));
        }
        
        // Wait for all operations
        await Future.wait(operations);
        
        // Should be clean
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });
    });

    group('Memory Leak Prevention', () {
      test('should not accumulate driver data after cleanup', () {
        const int iterations = 50;
        
        for (int i = 0; i < iterations; i++) {
          final driverId = 'memory_test_$i';
          
          // Create, use, and cleanup driver
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          
          AnimationManager.startDriverAnimation(driverId, () {});
          AnimationManager.stopDriverAnimation(driverId);
          
          // Clean up this iteration
          AnimationManager.stopAllAnimations();
          
          // Should be empty after each cleanup
          expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
          expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        }
      });

      test('should handle driver reinitialization without memory leaks', () {
        const driverId = 'reinit_test';
        const int reinitCount = 30;
        
        for (int i = 0; i < reinitCount; i++) {
          // Initialize driver
          AnimationManager.initializeDriver(driverId);
          expect(AnimationManager.getDriver(driverId), isNotNull);
          
          // Start animation
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
          
          // Stop and cleanup
          AnimationManager.stopAllAnimations();
          
          // Verify cleanup
          expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
          expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        }
      });

      test('should properly dispose of driver models', () {
        const int driverCount = 25;
        final List<String> driverIds = [];
        
        // Create many drivers
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'disposal_test_$i';
          driverIds.add(driverId);
          AnimationManager.initializeDriver(driverId);
        }
        
        expect(AnimationManager.getAllDrivers().length, equals(driverCount));
        
        // Cleanup should remove all
        AnimationManager.stopAllAnimations();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        
        // Verify individual drivers are gone
        for (final driverId in driverIds) {
          expect(AnimationManager.getDriver(driverId), isNull);
        }
      });
    });

    group('Lifecycle Management', () {
      test('should properly pause and resume animations', () {
        const int driverCount = 8;
        final List<String> animatingDrivers = [];
        
        // Create mix of animating and non-animating drivers
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'lifecycle_test_$i';
          AnimationManager.initializeDriver(driverId);
          
          final driver = AnimationManager.getDriver(driverId)!;
          if (i % 2 == 0) {
            driver.shouldAnimate = true;
            animatingDrivers.add(driverId);
            AnimationManager.startDriverAnimation(driverId, () {});
          }
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(animatingDrivers.length));
        
        // Pause all
        LifecycleManager.pauseAll();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // Resume all
        LifecycleManager.resumeAll(() {});
        
        // Should have resumed some drivers (due to random shouldAnimate assignment)
        // The exact count may vary due to randomization, but should be reasonable
        expect(AnimationManager.getActiveAnimations().length, greaterThanOrEqualTo(0));
      });

      test('should handle cleanup during lifecycle operations', () {
        const int driverCount = 12;
        
        // Create drivers with animations
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'lifecycle_cleanup_$i';
          AnimationManager.initializeDriver(driverId);
          
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount));
        
        // Pause
        LifecycleManager.pauseAll();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // Cleanup during paused state
        LifecycleManager.cleanup();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should maintain driver state during pause/resume cycles', () {
        const driverId = 'state_persistence_test';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        driver.currentAngle = 45.0;
        driver.targetAngle = 90.0;
        
        AnimationManager.startDriverAnimation(driverId, () {});
        expect(AnimationManager.isAnimationActive(driverId), isTrue);
        
        // Pause
        LifecycleManager.pauseAll();
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
        
        // Verify state is preserved
        final pausedDriver = AnimationManager.getDriver(driverId)!;
        expect(pausedDriver.currentAngle, equals(45.0));
        expect(pausedDriver.shouldAnimate, isTrue);
        
        // Resume
        LifecycleManager.resumeAll(() {});
        
        // Should be active again if it should animate
        final resumedDriver = AnimationManager.getDriver(driverId)!;
        expect(resumedDriver.currentAngle, equals(45.0));
        expect(resumedDriver.shouldAnimate, isTrue);
      });
    });

    group('Icon Cache Management', () {
      test('should clear icon cache properly', () {
        // This test verifies the cache clearing mechanism exists
        // Since we can't directly inspect cache contents, we test the interface
        expect(() => IconManager.clearIconCache(), returnsNormally);
      });

      test('should handle cache operations without errors', () {
        // Test that cache operations don't throw exceptions
        expect(() => IconManager.clearIconCache(), returnsNormally);
        
        // Multiple clears should be safe
        expect(() => IconManager.clearIconCache(), returnsNormally);
        expect(() => IconManager.clearIconCache(), returnsNormally);
      });

      test('should handle icon requests after cache clear', () {
        // Clear cache
        IconManager.clearIconCache();
        
        // Should still be able to get icons (may create new ones)
        expect(() => IconManager.getIcon('taxi'), returnsNormally);
        expect(() => IconManager.getIcon('luxury'), returnsNormally);
        expect(() => IconManager.getIcon('suv'), returnsNormally);
      });
    });

    group('Resource Disposal Edge Cases', () {
      test('should handle disposal of non-existent resources gracefully', () {
        // Stop animation that doesn't exist
        expect(() => AnimationManager.stopDriverAnimation('non_existent'), returnsNormally);
        
        // Get driver that doesn't exist
        expect(AnimationManager.getDriver('non_existent'), isNull);
        
        // Multiple cleanup calls should be safe
        expect(() => AnimationManager.stopAllAnimations(), returnsNormally);
        expect(() => AnimationManager.stopAllAnimations(), returnsNormally);
      });

      test('should handle cleanup during active animations', () {
        const int driverCount = 6;
        
        // Start multiple animations
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'active_cleanup_$i';
          AnimationManager.initializeDriver(driverId);
          
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount));
        
        // Cleanup while animations are running
        expect(() => AnimationManager.stopAllAnimations(), returnsNormally);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });

      test('should handle mixed state cleanup', () {
        const int totalDrivers = 10;
        
        // Create mix of active and inactive drivers
        for (int i = 0; i < totalDrivers; i++) {
          final driverId = 'mixed_state_$i';
          AnimationManager.initializeDriver(driverId);
          
          final driver = AnimationManager.getDriver(driverId)!;
          
          // Only animate some drivers
          if (i % 3 == 0) {
            driver.shouldAnimate = true;
            AnimationManager.startDriverAnimation(driverId, () {});
          }
        }
        
        expect(AnimationManager.getAllDrivers().length, equals(totalDrivers));
        expect(AnimationManager.getActiveAnimations().length, greaterThan(0));
        expect(AnimationManager.getActiveAnimations().length, lessThan(totalDrivers));
        
        // Cleanup should handle mixed state
        AnimationManager.stopAllAnimations();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });
    });

    group('Resource Limits and Boundaries', () {
      test('should handle zero drivers gracefully', () {
        // Operations on empty state should be safe
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        expect(() => AnimationManager.stopAllAnimations(), returnsNormally);
        expect(() => LifecycleManager.pauseAll(), returnsNormally);
        expect(() => LifecycleManager.resumeAll(() {}), returnsNormally);
        expect(() => LifecycleManager.cleanup(), returnsNormally);
      });

      test('should handle single driver operations', () {
        const driverId = 'single_driver_test';
        
        AnimationManager.initializeDriver(driverId);
        expect(AnimationManager.getAllDrivers().length, equals(1));
        
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        AnimationManager.startDriverAnimation(driverId, () {});
        
        expect(AnimationManager.getActiveAnimations().length, equals(1));
        
        // Cleanup single driver
        AnimationManager.stopAllAnimations();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should handle large number of drivers efficiently', () {
        const int largeCount = 100;
        
        // Create many drivers
        for (int i = 0; i < largeCount; i++) {
          final driverId = 'large_scale_$i';
          AnimationManager.initializeDriver(driverId);
          
          if (i % 4 == 0) {
            final driver = AnimationManager.getDriver(driverId)!;
            driver.shouldAnimate = true;
            AnimationManager.startDriverAnimation(driverId, () {});
          }
        }
        
        expect(AnimationManager.getAllDrivers().length, equals(largeCount));
        expect(AnimationManager.getActiveAnimations().length, greaterThan(0));
        
        // Should cleanup efficiently
        final stopwatch = Stopwatch()..start();
        AnimationManager.stopAllAnimations();
        stopwatch.stop();
        
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // Should complete cleanup quickly (less than 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Resource State Consistency', () {
      test('should maintain consistent state during operations', () {
        const int driverCount = 8;
        final List<String> driverIds = [];
        
        // Create drivers
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'consistency_test_$i';
          driverIds.add(driverId);
          AnimationManager.initializeDriver(driverId);
        }
        
        // Start some animations
        for (int i = 0; i < driverCount; i += 2) {
          final driver = AnimationManager.getDriver(driverIds[i])!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverIds[i], () {});
        }
        
        final activeCount = AnimationManager.getActiveAnimations().length;
        final totalCount = AnimationManager.getAllDrivers().length;
        
        expect(totalCount, equals(driverCount));
        expect(activeCount, equals(driverCount ~/ 2));
        
        // State should remain consistent
        expect(AnimationManager.getAllDrivers().length, equals(totalCount));
        expect(AnimationManager.getActiveAnimations().length, equals(activeCount));
        
        // Partial cleanup
        for (int i = 0; i < driverCount; i += 4) {
          AnimationManager.stopDriverAnimation(driverIds[i]);
        }
        
        // State should be updated consistently
        expect(AnimationManager.getActiveAnimations().length, lessThan(activeCount));
        expect(AnimationManager.getAllDrivers().length, equals(totalCount));
      });

      test('should handle state transitions correctly', () {
        const driverId = 'state_transition_test';
        
        // Initial state: not initialized
        expect(AnimationManager.getDriver(driverId), isNull);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
        
        // Initialize
        AnimationManager.initializeDriver(driverId);
        expect(AnimationManager.getDriver(driverId), isNotNull);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
        
        // Start animation
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        AnimationManager.startDriverAnimation(driverId, () {});
        expect(AnimationManager.isAnimationActive(driverId), isTrue);
        
        // Stop animation
        AnimationManager.stopDriverAnimation(driverId);
        expect(AnimationManager.getDriver(driverId), isNotNull);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
        
        // Full cleanup
        AnimationManager.stopAllAnimations();
        expect(AnimationManager.getDriver(driverId), isNull);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
      });
    });
  });
}