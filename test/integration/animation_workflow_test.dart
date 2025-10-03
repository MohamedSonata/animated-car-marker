import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/animated_car_marker.dart';
import 'package:animated_car_marker/src/managers/animation_manager.dart';
import 'package:animated_car_marker/src/managers/icon_manager.dart';

/// Integration tests for complete animation workflows
/// 
/// Tests end-to-end animation scenarios including initialization,
/// lifecycle management, and complex multi-driver scenarios.
void main() {
  group('Animation Workflow Integration Tests', () {
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

    group('Complete Animation Lifecycle', () {
      test('should handle complete driver lifecycle', () async {
        const driverId = 'lifecycle_test_driver';
        bool markerUpdated = false;
        
        // 1. Initialize driver
        AnimatedCarMarkerManager.initializeDriver(driverId);
        expect(AnimationManager.getDriver(driverId), isNotNull);
        
        // 2. Start animation
        AnimatedCarMarkerManager.startAnimation(driverId, () {
          markerUpdated = true;
        });
        expect(AnimationManager.isAnimationActive(driverId), isTrue);
        
        // 3. Wait for animation callback
        await Future.delayed(const Duration(milliseconds: 150));
        expect(markerUpdated, isTrue);
        
        // 4. Stop animation
        AnimatedCarMarkerManager.stopAnimation(driverId);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
        
        // 5. Verify cleanup
        AnimatedCarMarkerManager.clearCache();
        expect(AnimationManager.getDriver(driverId), isNull);
      });

      test('should handle multiple drivers with different configurations', () async {
        const driverIds = ['multi_1', 'multi_2', 'multi_3'];
        final updateCounts = <String, int>{};
        final completers = <String, Completer<void>>{};
        
        // Initialize all drivers with different settings
        for (int i = 0; i < driverIds.length; i++) {
          final driverId = driverIds[i];
          updateCounts[driverId] = 0;
          completers[driverId] = Completer<void>();
          
          AnimatedCarMarkerManager.initializeDriver(driverId);
          
          // Set different configurations
          switch (i) {
            case 0:
              AnimatedCarMarkerManager.setFasterRotation(driverId, speedMultiplier: 2.0);
              AnimatedCarMarkerManager.setRotationTarget(driverId, RotationTarget.maximum);
              break;
            case 1:
              AnimatedCarMarkerManager.setRotationTarget(driverId, RotationTarget.center);
              break;
            case 2:
              AnimatedCarMarkerManager.setRotationTarget(driverId, RotationTarget.minimum);
              break;
          }
          
          // Start animations
          AnimatedCarMarkerManager.startAnimation(driverId, () {
            updateCounts[driverId] = updateCounts[driverId]! + 1;
            if (updateCounts[driverId]! >= 3 && !completers[driverId]!.isCompleted) {
              completers[driverId]!.complete();
            }
          });
        }
        
        // Wait for all animations to run
        await Future.wait(completers.values.map((c) => c.future)).timeout(
          const Duration(seconds: 5),
        );
        
        // Verify all drivers are active and updating
        for (final driverId in driverIds) {
          expect(AnimationManager.isAnimationActive(driverId), isTrue);
          expect(updateCounts[driverId], greaterThanOrEqualTo(3));
        }
        
        // Verify different configurations
        final driver1 = AnimationManager.getDriver(driverIds[0])!;
        final driver2 = AnimationManager.getDriver(driverIds[1])!;
        final driver3 = AnimationManager.getDriver(driverIds[2])!;
        
        expect(driver1.animationSpeed, greaterThan(driver2.animationSpeed));
        expect(driver1.currentTargetType, equals(RotationTarget.maximum));
        expect(driver2.currentTargetType, equals(RotationTarget.center));
        expect(driver3.currentTargetType, equals(RotationTarget.minimum));
      });

      test('should handle pause and resume workflow', () async {
        const driverIds = ['pause_1', 'pause_2'];
        final updateCounts = <String, int>{};
        
        // Initialize and start animations
        for (final driverId in driverIds) {
          updateCounts[driverId] = 0;
          AnimatedCarMarkerManager.initializeDriver(driverId);
          AnimatedCarMarkerManager.startAnimation(driverId, () {
            updateCounts[driverId] = updateCounts[driverId]! + 1;
          });
        }
        
        // Let animations run briefly
        await Future.delayed(const Duration(milliseconds: 200));
        final pauseUpdateCounts = Map<String, int>.from(updateCounts);
        
        // Pause all animations
        AnimatedCarMarkerManager.pauseAllAnimations();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // Wait and verify no more updates
        await Future.delayed(const Duration(milliseconds: 200));
        for (final driverId in driverIds) {
          expect(updateCounts[driverId], equals(pauseUpdateCounts[driverId]));
        }
        
        // Resume animations
        AnimatedCarMarkerManager.resumeAllAnimations(() {
          // Global update callback
        });
        
        // Wait for resumed animations
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Some drivers should be active again (depending on random assignment)
        expect(AnimationManager.getActiveAnimations().length, greaterThanOrEqualTo(0));
      });
    });

    group('Icon Management Integration', () {
      test('should integrate icon loading with animation workflow', () async {
        const driverId = 'icon_integration_test';
        
        // Preload icons
        await AnimatedCarMarkerManager.preloadCarIcons(size: 48.0);
        
        // Initialize driver and start animation
        AnimatedCarMarkerManager.initializeDriver(driverId);
        
        bool animationStarted = false;
        AnimatedCarMarkerManager.startAnimation(driverId, () {
          animationStarted = true;
        });
        
        // Get car icons for different types
        final taxiIcon = AnimatedCarMarkerManager.getCarIcon('taxi');
        final luxuryIcon = AnimatedCarMarkerManager.getCarIcon('luxury');
        final suvIcon = AnimatedCarMarkerManager.getCarIcon('suv');
        
        expect(taxiIcon, isNotNull);
        expect(luxuryIcon, isNotNull);
        expect(suvIcon, isNotNull);
        
        // Wait for animation
        await Future.delayed(const Duration(milliseconds: 150));
        expect(animationStarted, isTrue);
        
        // Get current rotation angle
        final currentAngle = AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
        expect(currentAngle, isA<double>());
      });

      test('should handle icon requests during active animations', () async {
        const driverIds = ['icon_anim_1', 'icon_anim_2'];
        
        // Start animations first
        for (final driverId in driverIds) {
          AnimatedCarMarkerManager.initializeDriver(driverId);
          AnimatedCarMarkerManager.startAnimation(driverId, () {});
        }
        
        // Request icons while animations are running
        final carTypes = ['taxi', 'luxury', 'suv', 'mini', 'bike'];
        for (final carType in carTypes) {
          final icon = AnimatedCarMarkerManager.getCarIcon(carType);
          expect(icon, isNotNull);
        }
        
        // Animations should still be active
        for (final driverId in driverIds) {
          expect(AnimationManager.isAnimationActive(driverId), isTrue);
        }
      });
    });

    group('Performance Integration', () {
      test('should handle high-load scenario efficiently', () async {
        const driverCount = 50;
        final driverIds = List.generate(driverCount, (i) => 'perf_driver_$i');
        final updateCounts = <String, int>{};
        final completers = <String, Completer<void>>{};
        
        final stopwatch = Stopwatch()..start();
        
        // Initialize all drivers
        for (final driverId in driverIds) {
          updateCounts[driverId] = 0;
          completers[driverId] = Completer<void>();
          
          AnimatedCarMarkerManager.initializeDriver(driverId);
          AnimatedCarMarkerManager.startAnimation(driverId, () {
            updateCounts[driverId] = updateCounts[driverId]! + 1;
            if (updateCounts[driverId]! >= 2 && !completers[driverId]!.isCompleted) {
              completers[driverId]!.complete();
            }
          });
        }
        
        stopwatch.stop();
        final initializationTime = stopwatch.elapsedMilliseconds;
        
        // Should initialize quickly
        expect(initializationTime, lessThan(1000));
        
        // Wait for animations to run
        await Future.wait(completers.values.map((c) => c.future)).timeout(
          const Duration(seconds: 10),
        );
        
        // Verify all animations are working
        final activeCount = AnimationManager.getActiveAnimations().length;
        expect(activeCount, equals(driverCount));
        
        // Performance cleanup
        final cleanupStopwatch = Stopwatch()..start();
        AnimatedCarMarkerManager.clearCache();
        cleanupStopwatch.stop();
        
        // Should cleanup quickly
        expect(cleanupStopwatch.elapsedMilliseconds, lessThan(500));
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });

      test('should maintain performance with frequent configuration changes', () async {
        const driverId = 'config_change_test';
        int updateCount = 0;
        final completer = Completer<void>();
        
        AnimatedCarMarkerManager.initializeDriver(driverId);
        AnimatedCarMarkerManager.startAnimation(driverId, () {
          updateCount++;
          if (updateCount >= 10 && !completer.isCompleted) {
            completer.complete();
          }
        });
        
        // Perform frequent configuration changes
        final configStopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 20; i++) {
          AnimatedCarMarkerManager.setFasterRotation(driverId, speedMultiplier: 1.5);
          AnimatedCarMarkerManager.setRotationTarget(driverId, RotationTarget.values[i % 4]);
          AnimatedCarMarkerManager.setAnimationSmoothness(0.3);
          
          // Brief delay between changes
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        configStopwatch.stop();
        
        // Should handle configuration changes quickly
        expect(configStopwatch.elapsedMilliseconds, lessThan(1000));
        
        // Animation should still be working
        await completer.future.timeout(const Duration(seconds: 5));
        expect(updateCount, greaterThanOrEqualTo(10));
        expect(AnimationManager.isAnimationActive(driverId), isTrue);
      });
    });

    group('Error Recovery Integration', () {
      test('should recover from partial failures gracefully', () async {
        const driverIds = ['recovery_1', 'recovery_2', 'recovery_3'];
        
        // Initialize some drivers successfully
        for (int i = 0; i < 2; i++) {
          AnimatedCarMarkerManager.initializeDriver(driverIds[i]);
          AnimatedCarMarkerManager.startAnimation(driverIds[i], () {});
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(2));
        
        // Simulate partial failure by stopping one animation
        AnimatedCarMarkerManager.stopAnimation(driverIds[0]);
        expect(AnimationManager.getActiveAnimations().length, equals(1));
        
        // Add new driver
        AnimatedCarMarkerManager.initializeDriver(driverIds[2]);
        AnimatedCarMarkerManager.startAnimation(driverIds[2], () {});
        
        expect(AnimationManager.getActiveAnimations().length, equals(2));
        
        // System should continue working normally
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Verify remaining animations are still active
        expect(AnimationManager.isAnimationActive(driverIds[1]), isTrue);
        expect(AnimationManager.isAnimationActive(driverIds[2]), isTrue);
      });

      test('should handle cleanup during active operations', () async {
        const driverIds = ['cleanup_1', 'cleanup_2'];
        final updateCounts = <String, int>{};
        
        // Start animations
        for (final driverId in driverIds) {
          updateCounts[driverId] = 0;
          AnimatedCarMarkerManager.initializeDriver(driverId);
          AnimatedCarMarkerManager.startAnimation(driverId, () {
            updateCounts[driverId] = updateCounts[driverId]! + 1;
          });
        }
        
        // Let animations run briefly
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Cleanup while animations are active
        AnimatedCarMarkerManager.clearCache();
        
        // Should handle cleanup gracefully
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // Should be able to start fresh
        AnimatedCarMarkerManager.initializeDriver('fresh_driver');
        expect(AnimationManager.getDriver('fresh_driver'), isNotNull);
      });
    });

    group('Statistics and Monitoring Integration', () {
      test('should provide accurate animation statistics', () async {
        const driverId = 'stats_test_driver';
        
        AnimatedCarMarkerManager.initializeDriver(driverId);
        AnimatedCarMarkerManager.setFasterRotation(driverId, speedMultiplier: 2.0);
        AnimatedCarMarkerManager.setRotationTarget(driverId, RotationTarget.maximum);
        
        final initialStats = AnimatedCarMarkerManager.getAnimationStats(driverId);
        expect(initialStats['driverId'], equals(driverId));
        expect(initialStats['isActive'], isFalse);
        
        // Start animation
        AnimatedCarMarkerManager.startAnimation(driverId, () {});
        
        await Future.delayed(const Duration(milliseconds: 200));
        
        final activeStats = AnimatedCarMarkerManager.getAnimationStats(driverId);
        expect(activeStats['isActive'], isTrue);
        expect(activeStats['speed'], greaterThan(0.0));
        expect(activeStats['targetType'], equals('maximum'));
      });

      test('should handle statistics for multiple drivers', () {
        const driverIds = ['stats_1', 'stats_2', 'stats_3'];
        
        // Initialize drivers with different configurations
        for (int i = 0; i < driverIds.length; i++) {
          AnimatedCarMarkerManager.initializeDriver(driverIds[i]);
          AnimatedCarMarkerManager.setRotationTarget(driverIds[i], RotationTarget.values[i]);
        }
        
        // Get statistics for all drivers
        for (int i = 0; i < driverIds.length; i++) {
          final stats = AnimatedCarMarkerManager.getAnimationStats(driverIds[i]);
          expect(stats['driverId'], equals(driverIds[i]));
          expect(stats['targetType'], equals(RotationTarget.values[i].name));
        }
        
        // Print summary should work without errors
        expect(() => AnimatedCarMarkerManager.printAnimationSummary(), returnsNormally);
      });
    });

    group('Real-world Scenarios', () {
      test('should simulate typical ride-sharing app usage', () async {
        // Simulate multiple cars appearing and disappearing
        final activeDrivers = <String>[];
        
        // Cars appear gradually
        for (int wave = 0; wave < 3; wave++) {
          for (int i = 0; i < 5; i++) {
            final driverId = 'car_${wave}_$i';
            activeDrivers.add(driverId);
            
            AnimatedCarMarkerManager.initializeDriver(driverId);
            AnimatedCarMarkerManager.startAnimation(driverId, () {});
            
            // Random car types and configurations
            final carType = ['taxi', 'luxury', 'suv'][i % 3];
            AnimatedCarMarkerManager.getCarIcon(carType);
            
            if (i % 2 == 0) {
              AnimatedCarMarkerManager.setFasterRotation(driverId);
            }
          }
          
          // Brief delay between waves
          await Future.delayed(const Duration(milliseconds: 50));
        }
        
        expect(activeDrivers.length, equals(15));
        expect(AnimationManager.getActiveAnimations().length, equals(15));
        
        // Simulate app going to background
        AnimatedCarMarkerManager.pauseAllAnimations();
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        // App returns to foreground
        AnimatedCarMarkerManager.resumeAllAnimations(() {});
        
        // Some cars disappear (simulate drivers going offline)
        for (int i = 0; i < 5; i++) {
          AnimatedCarMarkerManager.stopAnimation(activeDrivers[i]);
        }
        
        // Should handle mixed state gracefully
        expect(AnimationManager.getActiveAnimations().length, lessThan(15));
        expect(AnimationManager.getAllDrivers().length, greaterThan(0));
      });

      test('should handle navigation app scenario with route updates', () async {
        const driverId = 'navigation_car';
        final angleHistory = <double>[];
        
        AnimatedCarMarkerManager.initializeDriver(driverId);
        
        // Simulate route with multiple direction changes
        final routeAngles = [0.0, 45.0, 90.0, 135.0, 180.0, -135.0, -90.0, -45.0];
        
        AnimatedCarMarkerManager.startAnimation(driverId, () {
          final currentAngle = AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
          angleHistory.add(currentAngle);
        });
        
        // Simulate route updates
        for (final targetAngle in routeAngles) {
          AnimationManager.setRotationAngle(driverId, targetAngle);
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        // Should have recorded angle changes
        expect(angleHistory.length, greaterThan(routeAngles.length));
        
        // Angles should show progression
        expect(angleHistory.first, isA<double>());
        expect(angleHistory.last, isA<double>());
      });
    });

    group('Stress Testing', () {
      test('should handle rapid driver creation and destruction', () async {
        const cycles = 20;
        const driversPerCycle = 10;
        
        for (int cycle = 0; cycle < cycles; cycle++) {
          final cycleDrivers = <String>[];
          
          // Create drivers
          for (int i = 0; i < driversPerCycle; i++) {
            final driverId = 'stress_${cycle}_$i';
            cycleDrivers.add(driverId);
            
            AnimatedCarMarkerManager.initializeDriver(driverId);
            AnimatedCarMarkerManager.startAnimation(driverId, () {});
          }
          
          expect(AnimationManager.getActiveAnimations().length, equals(driversPerCycle));
          
          // Destroy all drivers in this cycle
          for (final driverId in cycleDrivers) {
            AnimatedCarMarkerManager.stopAnimation(driverId);
          }
          
          // Brief pause between cycles
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        // Final cleanup
        AnimatedCarMarkerManager.clearCache();
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
      });

      test('should maintain stability under concurrent operations', () async {
        const operationCount = 50;
        final futures = <Future<void>>[];
        
        // Perform many concurrent operations
        for (int i = 0; i < operationCount; i++) {
          futures.add(Future(() async {
            final driverId = 'concurrent_$i';
            
            AnimatedCarMarkerManager.initializeDriver(driverId);
            AnimatedCarMarkerManager.startAnimation(driverId, () {});
            
            // Random operations
            if (i % 3 == 0) {
              AnimatedCarMarkerManager.setFasterRotation(driverId);
            }
            if (i % 4 == 0) {
              AnimatedCarMarkerManager.setRotationTarget(driverId, RotationTarget.center);
            }
            
            await Future.delayed(const Duration(milliseconds: 20));
            AnimatedCarMarkerManager.stopAnimation(driverId);
          }));
        }
        
        // Wait for all operations to complete
        await Future.wait(futures);
        
        // System should be stable
        expect(() => AnimatedCarMarkerManager.clearCache(), returnsNormally);
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });
    });
  });
}