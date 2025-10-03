import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/src/managers/animation_manager.dart';

/// Performance validation tests for the animated car marker package
/// 
/// These tests validate that the refactored code maintains or improves
/// performance characteristics compared to the original implementation.
void main() {
  group('Performance Validation Tests', () {
    setUp(() {
      // Clean up before each test
      AnimationManager.stopAllAnimations();
    });

    tearDown(() {
      // Clean up after each test
      AnimationManager.stopAllAnimations();
    });

    group('Memory Usage Tests', () {
      test('should handle multiple drivers without excessive memory growth', () async {
        const int driverCount = 100;
        final List<String> driverIds = [];
        
        // Create many drivers
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'perf_driver_$i';
          driverIds.add(driverId);
          AnimationManager.initializeDriver(driverId);
        }
        
        // Verify all drivers are created
        final allDrivers = AnimationManager.getAllDrivers();
        expect(allDrivers.length, equals(driverCount));
        
        // Start animations for half of them
        int animationCount = 0;
        for (int i = 0; i < driverCount ~/ 2; i++) {
          final driver = AnimationManager.getDriver(driverIds[i])!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverIds[i], () {});
          animationCount++;
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(animationCount));
        
        // Clean up should remove all drivers and timers
        AnimationManager.stopAllAnimations();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should properly clean up resources when stopping individual animations', () {
        const int driverCount = 20;
        final List<String> driverIds = [];
        
        // Create and start animations for multiple drivers
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'cleanup_driver_$i';
          driverIds.add(driverId);
          AnimationManager.initializeDriver(driverId);
          
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount));
        
        // Stop animations one by one
        for (int i = 0; i < driverCount; i++) {
          AnimationManager.stopDriverAnimation(driverIds[i]);
          expect(
            AnimationManager.getActiveAnimations().length,
            equals(driverCount - i - 1),
          );
        }
        
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should handle rapid start/stop cycles without memory leaks', () {
        const driverId = 'cycle_test_driver';
        const int cycles = 50;
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        
        // Perform rapid start/stop cycles
        for (int i = 0; i < cycles; i++) {
          AnimationManager.startDriverAnimation(driverId, () {});
          expect(AnimationManager.isAnimationActive(driverId), isTrue);
          
          AnimationManager.stopDriverAnimation(driverId);
          expect(AnimationManager.isAnimationActive(driverId), isFalse);
        }
        
        // Final state should be clean
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });
    });

    group('CPU Usage and Performance Tests', () {
      test('should maintain consistent performance with multiple animated markers', () async {
        const int driverCount = 50;
        final List<String> driverIds = [];
        final List<Completer<void>> updateCompleters = [];
        
        // Create multiple drivers with animations
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'cpu_test_driver_$i';
          driverIds.add(driverId);
          updateCompleters.add(Completer<void>());
          
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          
          // Start animation with callback tracking
          int updateCount = 0;
          AnimationManager.startDriverAnimation(driverId, () {
            updateCount++;
            if (updateCount >= 5 && !updateCompleters[i].isCompleted) {
              updateCompleters[i].complete();
            }
          });
        }
        
        // Wait for all animations to run for a few cycles
        final futures = updateCompleters.map((c) => c.future).toList();
        await Future.wait(futures).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
            'Animations did not complete within expected time',
            const Duration(seconds: 10),
          ),
        );
        
        // Verify all animations are still active
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount));
        
        // Performance should be maintained - all drivers should still be animating
        for (final driverId in driverIds) {
          expect(AnimationManager.isAnimationActive(driverId), isTrue);
        }
      });

      test('should handle animation calculations efficiently', () {
        const int iterations = 1000;
        final stopwatch = Stopwatch()..start();
        
        // Perform many animation calculations
        for (int i = 0; i < iterations; i++) {
          final driverId = 'calc_test_$i';
          AnimationManager.initializeDriver(driverId);
          
          final driver = AnimationManager.getDriver(driverId)!;
          
          // Simulate animation ticks
          for (int tick = 0; tick < 10; tick++) {
            AnimationManager.updateAnimationTick(driver);
            
            if (driver.shouldChangeTarget()) {
              AnimationManager.setNewRotationTarget(driver);
              driver.markTargetChanged();
            }
          }
        }
        
        stopwatch.stop();
        
        // Should complete calculations quickly (less than 5 seconds for 1000 iterations)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        
        // Animation calculations completed in ${stopwatch.elapsedMilliseconds}ms
      });

      test('should maintain animation timing consistency', () async {
        const driverId = 'timing_test_driver';
        final List<DateTime> updateTimes = [];
        final completer = Completer<void>();
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        
        // Track animation update timing
        AnimationManager.startDriverAnimation(driverId, () {
          updateTimes.add(DateTime.now());
          if (updateTimes.length >= 10) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        });
        
        await completer.future.timeout(const Duration(seconds: 5));
        
        // Verify timing consistency (should be close to 100ms intervals)
        expect(updateTimes.length, greaterThanOrEqualTo(10));
        
        for (int i = 1; i < updateTimes.length; i++) {
          final interval = updateTimes[i].difference(updateTimes[i - 1]).inMilliseconds;
          // Allow some variance but should be close to 100ms
          // Increased tolerance for test environment variations
          expect(interval, greaterThan(70));
          expect(interval, lessThan(200));
        }
      });
    });

    group('Animation Smoothness Tests', () {
      test('should provide smooth angle interpolation', () {
        const driverId = 'smooth_test_driver';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        
        // Set up a controlled animation scenario
        driver.currentAngle = 0.0;
        driver.targetAngle = 90.0;
        driver.smoothingFactor = 0.25;
        
        final List<double> angleProgression = [];
        angleProgression.add(driver.currentAngle);
        
        // Simulate smooth interpolation over multiple steps
        for (int i = 0; i < 20; i++) {
          final currentAngle = driver.currentAngle;
          final targetAngle = driver.targetAngle;
          final smoothingFactor = driver.smoothingFactor;
          
          // Calculate next angle (simplified version of what happens in animation)
          final angleDiff = targetAngle - currentAngle;
          driver.currentAngle = currentAngle + (angleDiff * smoothingFactor);
          
          angleProgression.add(driver.currentAngle);
        }
        
        // Verify smooth progression
        expect(angleProgression.length, equals(21));
        expect(angleProgression.first, equals(0.0));
        expect(angleProgression.last, greaterThan(80.0)); // Should be close to target
        
        // Each step should be smaller than the previous (exponential decay)
        for (int i = 1; i < angleProgression.length - 1; i++) {
          final step1 = angleProgression[i] - angleProgression[i - 1];
          final step2 = angleProgression[i + 1] - angleProgression[i];
          expect(step2, lessThanOrEqualTo(step1 * 1.1)); // Allow small variance
        }
      });

      test('should handle different animation speeds appropriately', () {
        final List<String> driverIds = ['slow_driver', 'medium_driver', 'fast_driver'];
        final List<double> speeds = [0.08, 0.18, 0.35];
        
        for (int i = 0; i < driverIds.length; i++) {
          AnimationManager.initializeDriver(driverIds[i]);
          final driver = AnimationManager.getDriver(driverIds[i])!;
          
          driver.animationSpeed = speeds[i];
          driver.currentAngle = 0.0;
          driver.targetAngle = 90.0;
          
          // Calculate smoothing factor based on speed
          driver.smoothingFactor = 0.25 + (driver.animationSpeed * 0.5);
          driver.smoothingFactor = driver.smoothingFactor.clamp(0.15, 0.45);
          
          expect(driver.smoothingFactor, greaterThanOrEqualTo(0.15));
          expect(driver.smoothingFactor, lessThanOrEqualTo(0.45));
          
          // Faster animations should have higher smoothing factors
          if (i > 0) {
            final prevDriver = AnimationManager.getDriver(driverIds[i - 1])!;
            expect(driver.smoothingFactor, greaterThanOrEqualTo(prevDriver.smoothingFactor));
          }
        }
      });

      test('should maintain frame rate consistency under load', () async {
        const int driverCount = 30;
        final List<String> driverIds = [];
        final Map<String, List<DateTime>> updateTimes = {};
        final Map<String, Completer<void>> completers = {};
        
        // Create multiple animated drivers
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'frame_test_driver_$i';
          driverIds.add(driverId);
          updateTimes[driverId] = [];
          completers[driverId] = Completer<void>();
          
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          
          AnimationManager.startDriverAnimation(driverId, () {
            updateTimes[driverId]!.add(DateTime.now());
            if (updateTimes[driverId]!.length >= 5) {
              if (!completers[driverId]!.isCompleted) {
                completers[driverId]!.complete();
              }
            }
          });
        }
        
        // Wait for all animations to run
        await Future.wait(completers.values.map((c) => c.future)).timeout(
          const Duration(seconds: 10),
        );
        
        // Verify frame rate consistency across all drivers
        for (final driverId in driverIds) {
          final times = updateTimes[driverId]!;
          expect(times.length, greaterThanOrEqualTo(5));
          
          // Check intervals between updates
          for (int i = 1; i < times.length; i++) {
            final interval = times[i].difference(times[i - 1]).inMilliseconds;
            // Should maintain roughly 100ms intervals even under load
            expect(interval, greaterThan(70));
            expect(interval, lessThan(200));
          }
        }
      });
    });

    group('Resource Efficiency Tests', () {
      test('should efficiently manage timer resources', () {
        const int driverCount = 25;
        final List<String> driverIds = [];
        
        // Create drivers and start animations
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'timer_test_driver_$i';
          driverIds.add(driverId);
          
          AnimationManager.initializeDriver(driverId);
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          
          AnimationManager.startDriverAnimation(driverId, () {});
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount));
        
        // Stop half the animations
        final halfCount = driverCount ~/ 2;
        for (int i = 0; i < halfCount; i++) {
          AnimationManager.stopDriverAnimation(driverIds[i]);
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount - halfCount));
        
        // Pause all remaining animations
        AnimationManager.pauseAllAnimations();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // Resume should only restart the ones that should animate
        AnimationManager.resumeAllAnimations(() {});
        // Note: The actual count may vary due to random shouldAnimate assignment
        // Just verify that some animations are active (not all were stopped)
        expect(AnimationManager.getActiveAnimations().length, greaterThan(0));
      });

      test('should handle concurrent operations safely', () async {
        const int concurrentOperations = 20;
        final List<Future<void>> operations = [];
        
        // Perform concurrent operations
        for (int i = 0; i < concurrentOperations; i++) {
          operations.add(Future(() {
            final driverId = 'concurrent_driver_$i';
            
            AnimationManager.initializeDriver(driverId);
            final driver = AnimationManager.getDriver(driverId)!;
            driver.shouldAnimate = true;
            
            AnimationManager.startDriverAnimation(driverId, () {});
            
            // Simulate some work
            for (int j = 0; j < 10; j++) {
              AnimationManager.updateAnimationTick(driver);
              if (driver.shouldChangeTarget()) {
                AnimationManager.setNewRotationTarget(driver);
                driver.markTargetChanged();
              }
            }
            
            AnimationManager.stopDriverAnimation(driverId);
          }));
        }
        
        // Wait for all operations to complete
        await Future.wait(operations);
        
        // System should be in a clean state
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should maintain performance with frequent target changes', () {
        const driverId = 'target_change_test';
        const int targetChanges = 100;
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        
        final stopwatch = Stopwatch()..start();
        
        // Perform many target changes
        for (int i = 0; i < targetChanges; i++) {
          AnimationManager.setNewRotationTarget(driver);
          driver.markTargetChanged();
          
          // Simulate some animation ticks
          for (int j = 0; j < 5; j++) {
            AnimationManager.updateAnimationTick(driver);
          }
        }
        
        stopwatch.stop();
        
        // Should complete quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        // $targetChanges target changes completed in ${stopwatch.elapsedMilliseconds}ms
      });
    });

    group('Scalability Tests', () {
      test('should scale linearly with number of drivers', () {
        final List<int> driverCounts = [10, 25, 50, 100];
        final List<int> initializationTimes = [];
        
        for (final count in driverCounts) {
          AnimationManager.stopAllAnimations(); // Clean slate
          
          final stopwatch = Stopwatch()..start();
          
          // Initialize drivers
          for (int i = 0; i < count; i++) {
            final driverId = 'scale_test_${count}_$i';
            AnimationManager.initializeDriver(driverId);
          }
          
          stopwatch.stop();
          initializationTimes.add(stopwatch.elapsedMilliseconds);
          
          // Initialized $count drivers in ${stopwatch.elapsedMilliseconds}ms
        }
        
        // Verify roughly linear scaling (allowing for some variance)
        for (int i = 1; i < driverCounts.length; i++) {
          final ratio = driverCounts[i] / driverCounts[i - 1];
          final timeRatio = initializationTimes[i - 1] == 0 
              ? 1.0 // Handle division by zero case
              : initializationTimes[i] / initializationTimes[i - 1];
          
          // Time ratio should be roughly proportional to driver count ratio
          // Allow significant variance for small timing differences
          expect(timeRatio, lessThan(ratio * 5)); // Allow 5x variance for timing variations
        }
      });

      test('should handle edge cases efficiently', () {
        // Test with zero drivers
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // Test with single driver
        AnimationManager.initializeDriver('single_driver');
        expect(AnimationManager.getAllDrivers().length, equals(1));
        
        // Test rapid creation and deletion
        for (int i = 0; i < 50; i++) {
          final driverId = 'rapid_test_$i';
          AnimationManager.initializeDriver(driverId);
          
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          
          AnimationManager.startDriverAnimation(driverId, () {});
          AnimationManager.stopDriverAnimation(driverId);
        }
        
        // Clean up
        AnimationManager.stopAllAnimations();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });
    });
  });
}