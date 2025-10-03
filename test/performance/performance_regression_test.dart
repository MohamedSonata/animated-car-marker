import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/animated_car_marker.dart';
import 'package:animated_car_marker/src/managers/animation_manager.dart';
import 'package:animated_car_marker/src/managers/icon_manager.dart';
import 'package:animated_car_marker/src/utils/animation_calculator.dart';

/// Performance regression tests for the animated car marker package
/// 
/// These tests establish performance baselines and detect regressions
/// in critical operations like animation calculations, memory usage,
/// and system responsiveness.
void main() {
  group('Performance Regression Tests', () {
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

    group('Animation Calculation Performance', () {
      test('should perform angle calculations within performance baseline', () {
        const iterations = 10000;
        final random = math.Random(42);
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < iterations; i++) {
          final currentAngle = random.nextDouble() * 360;
          final targetAngle = random.nextDouble() * 360;
          final smoothingFactor = 0.25;
          
          AnimationCalculator.calculateSmoothedAngle(
            currentAngle: currentAngle,
            targetAngle: targetAngle,
            smoothingFactor: smoothingFactor,
          );
        }
        
        stopwatch.stop();
        
        // Baseline: Should complete 10,000 calculations in under 50ms
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
        
        if (kDebugMode) {
          print('Angle calculations: $iterations iterations in ${stopwatch.elapsedMilliseconds}ms');
        }
        if (kDebugMode) {
          print('Rate: ${(iterations / stopwatch.elapsedMilliseconds * 1000).round()} calculations/second');
        }
      });

      test('should perform angle difference calculations efficiently', () {
        const iterations = 50000;
        final random = math.Random(42);
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < iterations; i++) {
          final currentAngle = random.nextDouble() * 360;
          final targetAngle = random.nextDouble() * 360;
          
          AnimationCalculator.calculateAngleDifference(
            currentAngle: currentAngle,
            targetAngle: targetAngle,
          );
        }
        
        stopwatch.stop();
        
        // Baseline: Should complete 50,000 calculations in under 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        
        if (kDebugMode) {
          print('Angle differences: $iterations iterations in ${stopwatch.elapsedMilliseconds}ms');
        }
      });

      test('should perform target generation efficiently', () {
        const iterations = 20000;
        final random = math.Random(42);
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < iterations; i++) {
          final targetType = RotationTarget.values[i % RotationTarget.values.length];
          
          AnimationCalculator.generateRandomTarget(
            targetType: targetType,
            maxAngle: 180.0,
            random: random,
          );
        }
        
        stopwatch.stop();
        
        // Baseline: Should complete 20,000 generations in under 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        
        if (kDebugMode) {
          print('Target generation: $iterations iterations in ${stopwatch.elapsedMilliseconds}ms');
        }
      });
    });

    group('Driver Management Performance', () {
      test('should initialize drivers efficiently at scale', () {
        const driverCount = 1000;
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < driverCount; i++) {
          AnimationManager.initializeDriver('perf_driver_$i');
        }
        
        stopwatch.stop();
        
        // Baseline: Should initialize 1,000 drivers in under 200ms
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        
        expect(AnimationManager.getAllDrivers().length, equals(driverCount));
        
        if (kDebugMode) {
          print('Driver initialization: $driverCount drivers in ${stopwatch.elapsedMilliseconds}ms');
        }
        if (kDebugMode) {
          print('Rate: ${(driverCount / stopwatch.elapsedMilliseconds * 1000).round()} drivers/second');
        }
      });

      test('should start animations efficiently at scale', () {
        const driverCount = 500;
        
        // Pre-initialize drivers
        for (int i = 0; i < driverCount; i++) {
          AnimationManager.initializeDriver('anim_driver_$i');
          final driver = AnimationManager.getDriver('anim_driver_$i')!;
          driver.shouldAnimate = true;
        }
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < driverCount; i++) {
          AnimationManager.startDriverAnimation('anim_driver_$i', () {});
        }
        
        stopwatch.stop();
        
        // Baseline: Should start 500 animations in under 300ms
        expect(stopwatch.elapsedMilliseconds, lessThan(300));
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount));
        
        if (kDebugMode) {
          print('Animation startup: $driverCount animations in ${stopwatch.elapsedMilliseconds}ms');
        }
      });

      test('should stop animations efficiently at scale', () {
        const driverCount = 500;
        
        // Pre-initialize and start animations
        for (int i = 0; i < driverCount; i++) {
          AnimationManager.initializeDriver('stop_driver_$i');
          final driver = AnimationManager.getDriver('stop_driver_$i')!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation('stop_driver_$i', () {});
        }
        
        expect(AnimationManager.getActiveAnimations().length, equals(driverCount));
        
        final stopwatch = Stopwatch()..start();
        
        AnimationManager.stopAllAnimations();
        
        stopwatch.stop();
        
        // Baseline: Should stop 500 animations in under 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        
        if (kDebugMode) {
          print('Animation cleanup: $driverCount animations in ${stopwatch.elapsedMilliseconds}ms');
        }
      });
    });

    group('Memory Usage Performance', () {
      test('should maintain stable memory usage with driver churn', () {
        const cycles = 100;
        const driversPerCycle = 50;
        
        final stopwatch = Stopwatch()..start();
        
        for (int cycle = 0; cycle < cycles; cycle++) {
          // Create drivers
          for (int i = 0; i < driversPerCycle; i++) {
            final driverId = 'churn_${cycle}_$i';
            AnimationManager.initializeDriver(driverId);
            
            final driver = AnimationManager.getDriver(driverId)!;
            driver.shouldAnimate = true;
            AnimationManager.startDriverAnimation(driverId, () {});
          }
          
          // Immediately clean up
          AnimationManager.stopAllAnimations();
          
          // Verify cleanup
          expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
          expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        }
        
        stopwatch.stop();
        
        // Baseline: Should handle 5,000 total drivers (100 cycles × 50) in under 2 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        
        final totalDrivers = cycles * driversPerCycle;
        if (kDebugMode) {
          print('Memory churn test: $totalDrivers total drivers in ${stopwatch.elapsedMilliseconds}ms');
        }
      });

      test('should handle concurrent driver operations without memory leaks', () async {
        const concurrentOperations = 100;
        final futures = <Future<void>>[];
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < concurrentOperations; i++) {
          futures.add(Future(() {
            final driverId = 'concurrent_mem_$i';
            
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
        
        await Future.wait(futures);
        stopwatch.stop();
        
        // Baseline: Should complete 100 concurrent operations in under 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        // Should be clean after concurrent operations
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        if (kDebugMode) {
          print('Concurrent operations: $concurrentOperations operations in ${stopwatch.elapsedMilliseconds}ms');
        }
      });
    });

    group('Animation Tick Performance', () {
      test('should process animation ticks efficiently', () {
        const driverCount = 200;
        const ticksPerDriver = 100;
        
        // Initialize drivers
        final drivers = <String>[];
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'tick_driver_$i';
          drivers.add(driverId);
          AnimationManager.initializeDriver(driverId);
        }
        
        final stopwatch = Stopwatch()..start();
        
        // Process ticks for all drivers
        for (int tick = 0; tick < ticksPerDriver; tick++) {
          for (final driverId in drivers) {
            final driver = AnimationManager.getDriver(driverId)!;
            AnimationManager.updateAnimationTick(driver);
            
            if (driver.shouldChangeTarget()) {
              AnimationManager.setNewRotationTarget(driver);
              driver.markTargetChanged();
            }
          }
        }
        
        stopwatch.stop();
        
        final totalTicks = driverCount * ticksPerDriver;
        
        // Baseline: Should process 20,000 ticks in under 500ms
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        
        if (kDebugMode) {
          print('Animation ticks: $totalTicks ticks in ${stopwatch.elapsedMilliseconds}ms');
               print('Rate: ${(totalTicks / stopwatch.elapsedMilliseconds * 1000).round()} ticks/second');

        }
      });

      test('should handle target changes efficiently', () {
        const driverCount = 100;
        const targetChanges = 1000;
        
        // Initialize drivers
        final drivers = <String>[];
        for (int i = 0; i < driverCount; i++) {
          final driverId = 'target_driver_$i';
          drivers.add(driverId);
          AnimationManager.initializeDriver(driverId);
        }
        
        final stopwatch = Stopwatch()..start();
        
        // Force target changes
        for (int change = 0; change < targetChanges; change++) {
          final driverId = drivers[change % driverCount];
          final driver = AnimationManager.getDriver(driverId)!;
          
          AnimationManager.setNewRotationTarget(driver);
          driver.markTargetChanged();
        }
        
        stopwatch.stop();
        
        // Baseline: Should process 1,000 target changes in under 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        
        if (kDebugMode) {
          print('Target changes: $targetChanges changes in ${stopwatch.elapsedMilliseconds}ms');
        }
      });
    });

    group('Icon Management Performance', () {
      test('should load icons efficiently', () async {
        const loadCycles = 10;
        
        final stopwatch = Stopwatch()..start();
        
        for (int cycle = 0; cycle < loadCycles; cycle++) {
          // Clear cache to force reload
          IconManager.clearIconCache();
          
          // Load all car types
          final carTypes = ['taxi', 'luxury', 'suv', 'mini', 'bike'];
          for (final carType in carTypes) {
            IconManager.getIcon(carType);
          }
        }
        
        stopwatch.stop();
        
        // Baseline: Should complete 10 load cycles in under 500ms
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        
        if (kDebugMode) {
          print('Icon loading: $loadCycles cycles in ${stopwatch.elapsedMilliseconds}ms');
        }
      });

      test('should cache icons efficiently', () {
        const requestCount = 10000;
        final carTypes = ['taxi', 'luxury', 'suv', 'mini', 'bike'];
        
        // Pre-load icons
        for (final carType in carTypes) {
          IconManager.getIcon(carType);
        }
        
        final stopwatch = Stopwatch()..start();
        
        // Make many cached requests
        for (int i = 0; i < requestCount; i++) {
          final carType = carTypes[i % carTypes.length];
          IconManager.getIcon(carType);
        }
        
        stopwatch.stop();
        
        // Baseline: Should handle 10,000 cached requests in under 50ms
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
        
        if (kDebugMode) {
          print('Icon caching: $requestCount requests in ${stopwatch.elapsedMilliseconds}ms');
        }
      });
    });

    group('Lifecycle Performance', () {
      test('should handle pause/resume cycles efficiently', () {
        const driverCount = 300;
        const cycles = 20;
        
        // Initialize drivers
        for (int i = 0; i < driverCount; i++) {
          AnimationManager.initializeDriver('lifecycle_driver_$i');
          final driver = AnimationManager.getDriver('lifecycle_driver_$i')!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation('lifecycle_driver_$i', () {});
        }
        
        final stopwatch = Stopwatch()..start();
        
        for (int cycle = 0; cycle < cycles; cycle++) {
          // Pause all
          AnimationManager.pauseAllAnimations();
          expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
          
          // Resume all
          AnimationManager.resumeAllAnimations(() {});
        }
        
        stopwatch.stop();
        
        // Baseline: Should complete 20 pause/resume cycles in under 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        if (kDebugMode) {
          print('Lifecycle cycles: $cycles cycles with $driverCount drivers in ${stopwatch.elapsedMilliseconds}ms');
        }
      });

      test('should cleanup resources efficiently', () {
        const cleanupCycles = 50;
        const driversPerCycle = 100;
        
        final stopwatch = Stopwatch()..start();
        
        for (int cycle = 0; cycle < cleanupCycles; cycle++) {
          // Create drivers
          for (int i = 0; i < driversPerCycle; i++) {
            final driverId = 'cleanup_${cycle}_$i';
            AnimationManager.initializeDriver(driverId);
            final driver = AnimationManager.getDriver(driverId)!;
            driver.shouldAnimate = true;
            AnimationManager.startDriverAnimation(driverId, () {});
          }
          
          // Cleanup
          AnimationManager.stopAllAnimations();
        }
        
        stopwatch.stop();
        
        final totalDrivers = cleanupCycles * driversPerCycle;
        
        // Baseline: Should handle 5,000 total drivers in under 1.5 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(1500));
        
        if (kDebugMode) {
          print('Cleanup performance: $totalDrivers total drivers in ${stopwatch.elapsedMilliseconds}ms');
        }
      });
    });

    group('API Response Time Performance', () {
      test('should respond to API calls quickly', () {
        const driverId = 'api_perf_driver';
        const apiCalls = 10000;
        
        AnimationManager.initializeDriver(driverId);
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < apiCalls; i++) {
          // Mix of different API calls
          switch (i % 6) {
            case 0:
              AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
              break;
            case 1:
              AnimatedCarMarkerManager.shouldDriverAnimate(driverId);
              break;
            case 2:
              AnimatedCarMarkerManager.setFasterRotation(driverId);
              break;
            case 3:
              AnimatedCarMarkerManager.setNormalRotation(driverId);
              break;
            case 4:
              AnimatedCarMarkerManager.setRotationTarget(driverId, RotationTarget.center);
              break;
            case 5:
              AnimatedCarMarkerManager.getAnimationStats(driverId);
              break;
          }
        }
        
        stopwatch.stop();
        
        // Baseline: Should handle 10,000 API calls in under 200ms
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        
        if (kDebugMode) {
          print('API performance: $apiCalls calls in ${stopwatch.elapsedMilliseconds}ms');
                print('Average: ${(stopwatch.elapsedMicroseconds / apiCalls).toStringAsFixed(1)} μs/call');

        }
      });

      test('should maintain performance under concurrent API access', () async {
        const concurrentClients = 50;
        const callsPerClient = 100;
        
        // Initialize some drivers
        for (int i = 0; i < 10; i++) {
          AnimationManager.initializeDriver('concurrent_api_$i');
        }
        
        final stopwatch = Stopwatch()..start();
        
        final futures = <Future<void>>[];
        for (int client = 0; client < concurrentClients; client++) {
          futures.add(Future(() {
            for (int call = 0; call < callsPerClient; call++) {
              final driverId = 'concurrent_api_${call % 10}';
              
              // Random API calls
              switch (call % 4) {
                case 0:
                  AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
                  break;
                case 1:
                  AnimatedCarMarkerManager.getAnimationStats(driverId);
                  break;
                case 2:
                  AnimatedCarMarkerManager.setRotationTarget(driverId, RotationTarget.random);
                  break;
                case 3:
                  AnimatedCarMarkerManager.shouldDriverAnimate(driverId);
                  break;
              }
            }
          }));
        }
        
        await Future.wait(futures);
        stopwatch.stop();
        
        final totalCalls = concurrentClients * callsPerClient;
        
        // Baseline: Should handle 5,000 concurrent calls in under 500ms
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        
        if (kDebugMode) {
          print('Concurrent API: $totalCalls calls from $concurrentClients clients in ${stopwatch.elapsedMilliseconds}ms');
        }
      });
    });

    group('Overall System Performance', () {
      test('should maintain performance under realistic load', () async {
        const totalDrivers = 200;
        const operationDuration = Duration(seconds: 2);
        
        final stopwatch = Stopwatch()..start();
        
        // Create drivers gradually
        for (int i = 0; i < totalDrivers; i++) {
          final driverId = 'realistic_driver_$i';
          AnimationManager.initializeDriver(driverId);
          
          // Some drivers animate
          if (i % 3 == 0) {
            final driver = AnimationManager.getDriver(driverId)!;
            driver.shouldAnimate = true;
            AnimationManager.startDriverAnimation(driverId, () {});
          }
          
          // Simulate gradual addition
          if (i % 20 == 0) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
        
        final initTime = stopwatch.elapsedMilliseconds;
        
        // Run for specified duration
        await Future.delayed(operationDuration);
        
        // Cleanup
        AnimationManager.stopAllAnimations();
        final totalTime = stopwatch.elapsedMilliseconds;
        
        // Baseline: Should initialize 200 drivers in under 500ms
        expect(initTime, lessThan(500));
        
        // Should maintain stability during operation
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        
        if (kDebugMode) {
          print('Realistic load test: $totalDrivers drivers, init: ${initTime}ms, total: ${totalTime}ms');
        }
      });

      test('should demonstrate performance improvements over baseline', () {
        // This test serves as a benchmark for future optimizations
        const operationCount = 1000;
        
        final stopwatch = Stopwatch()..start();
        
        // Perform a mix of operations
        for (int i = 0; i < operationCount; i++) {
          final driverId = 'benchmark_$i';
          
          // Initialize
          AnimationManager.initializeDriver(driverId);
          
          // Configure
          AnimationManager.setFasterRotation(driverId);
          AnimationManager.setRotationTarget(driverId, RotationTarget.values[i % 4]);
          
          // Start animation
          final driver = AnimationManager.getDriver(driverId)!;
          driver.shouldAnimate = true;
          AnimationManager.startDriverAnimation(driverId, () {});
          
          // Simulate some ticks
          for (int tick = 0; tick < 5; tick++) {
            AnimationManager.updateAnimationTick(driver);
          }
          
          // Stop
          AnimationManager.stopDriverAnimation(driverId);
          
          // Cleanup every 100 operations to prevent memory buildup
          if (i % 100 == 99) {
            AnimationManager.stopAllAnimations();
          }
        }
        
        stopwatch.stop();
        
        // Baseline: Should complete 1,000 full operation cycles in under 2 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        
        if (kDebugMode) {
          print('Benchmark: $operationCount full cycles in ${stopwatch.elapsedMilliseconds}ms');
              print('Average: ${(stopwatch.elapsedMilliseconds / operationCount).toStringAsFixed(2)} ms/cycle');

        }
      });
    });
  });
}