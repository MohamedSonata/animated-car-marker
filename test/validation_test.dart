import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/animated_car_marker.dart';
import 'package:animated_car_marker/src/managers/animation_manager.dart';
import 'package:animated_car_marker/src/models/driver_animation_model.dart';
import 'package:animated_car_marker/src/models/rotation_target.dart';
import 'package:animated_car_marker/src/utils/animation_calculator.dart';
import 'package:animated_car_marker/src/constants/animation_constants.dart';

/// Comprehensive validation tests for core animation functionality
/// 
/// These tests validate that all animation features work identically
/// to the original implementation after refactoring.
void main() {
  group('Core Animation Functionality Validation', () {
    setUp(() {
      // Clean up before each test
      AnimationManager.stopAllAnimations();
    });

    tearDown(() {
      // Clean up after each test
      AnimationManager.stopAllAnimations();
    });

    group('Driver Initialization', () {
      test('should initialize driver with correct default values', () {
        const driverId = 'test_driver_1';
        
        // Initialize driver
        AnimationManager.initializeDriver(driverId);
        
        // Verify driver exists
        final driver = AnimationManager.getDriver(driverId);
        expect(driver, isNotNull);
        expect(driver!.driverId, equals(driverId));
        expect(driver.currentAngle, equals(0.0));
        expect(driver.animationTicks, equals(0));
        expect(driver.lastTargetChange, equals(0));
      });

      test('should not reinitialize existing driver', () {
        const driverId = 'test_driver_2';
        
        // Initialize driver twice
        AnimationManager.initializeDriver(driverId);
        final firstDriver = AnimationManager.getDriver(driverId);
        final firstTargetAngle = firstDriver!.targetAngle;
        
        AnimationManager.initializeDriver(driverId);
        final secondDriver = AnimationManager.getDriver(driverId);
        
        // Should be the same instance with same target
        expect(secondDriver!.targetAngle, equals(firstTargetAngle));
      });

      test('should assign random animation properties correctly', () {
        const driverId = 'test_driver_3';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId);
        
        expect(driver, isNotNull);
        expect(driver!.animationSpeed, greaterThan(0.0));
        expect(driver.smoothingFactor, greaterThan(0.0));
        expect(driver.targetChangeInterval, greaterThan(0));
        expect(RotationTarget.values.contains(driver.currentTargetType), isTrue);
      });
    });

    group('Animation State Management', () {
      test('should track animation active state correctly', () {
        const driverId = 'test_driver_4';
        
        // Initially not active
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
        
        // Initialize and start animation
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true; // Force animation
        
        AnimationManager.startDriverAnimation(driverId, () {
          // Marker update callback
        });
        
        // Should be active now
        expect(AnimationManager.isAnimationActive(driverId), isTrue);
        
        // Stop animation
        AnimationManager.stopDriverAnimation(driverId);
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
      });

      test('should get active animations list correctly', () {
        const driverId1 = 'test_driver_5a';
        const driverId2 = 'test_driver_5b';
        
        // Initialize drivers
        AnimationManager.initializeDriver(driverId1);
        AnimationManager.initializeDriver(driverId2);
        
        // Force animation for both
        AnimationManager.getDriver(driverId1)!.shouldAnimate = true;
        AnimationManager.getDriver(driverId2)!.shouldAnimate = true;
        
        // Start animations
        AnimationManager.startDriverAnimation(driverId1, () {});
        AnimationManager.startDriverAnimation(driverId2, () {});
        
        final activeAnimations = AnimationManager.getActiveAnimations();
        expect(activeAnimations.length, equals(2));
        expect(activeAnimations.contains(driverId1), isTrue);
        expect(activeAnimations.contains(driverId2), isTrue);
      });

      test('should handle pause and resume correctly', () {
        const driverId = 'test_driver_6';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        driver.shouldAnimate = true;
        
        // Start animation
        AnimationManager.startDriverAnimation(driverId, () {});
        expect(AnimationManager.isAnimationActive(driverId), isTrue);
        
        // Pause all
        AnimationManager.pauseAllAnimations();
        expect(AnimationManager.isAnimationActive(driverId), isFalse);
        
        // Resume all
        AnimationManager.resumeAllAnimations(() {});
        expect(AnimationManager.isAnimationActive(driverId), isTrue);
      });
    });

    group('Rotation Angle Management', () {
      test('should get current rotation angle correctly', () {
        const driverId = 'test_driver_7';
        const testAngle = 45.0;
        
        AnimationManager.initializeDriver(driverId);
        AnimationManager.setRotationAngle(driverId, testAngle);
        
        final currentAngle = AnimationManager.getCurrentRotationAngle(driverId);
        expect(currentAngle, equals(testAngle));
      });

      test('should clamp rotation angles to valid range', () {
        const driverId = 'test_driver_8';
        
        AnimationManager.initializeDriver(driverId);
        
        // Test maximum clamp
        AnimationManager.setRotationAngle(driverId, 200.0);
        expect(
          AnimationManager.getCurrentRotationAngle(driverId),
          equals(AnimationConstants.maxRotationAngle),
        );
        
        // Test minimum clamp
        AnimationManager.setRotationAngle(driverId, -200.0);
        expect(
          AnimationManager.getCurrentRotationAngle(driverId),
          equals(-AnimationConstants.maxRotationAngle),
        );
      });

      test('should handle rotation target changes correctly', () {
        const driverId = 'test_driver_9';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        
        // Test each rotation target type
        for (final targetType in RotationTarget.values) {
          AnimationManager.setRotationTarget(driverId, targetType);
          expect(driver.currentTargetType, equals(targetType));
          expect(
            driver.targetAngle.abs(),
            lessThanOrEqualTo(AnimationConstants.maxRotationAngle),
          );
        }
      });
    });

    group('Animation Speed and Smoothing', () {
      test('should set faster rotation correctly', () {
        const driverId = 'test_driver_10';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        final originalSpeed = driver.animationSpeed;
        
        AnimationManager.setFasterRotation(driverId, speedMultiplier: 2.0);
        expect(driver.animationSpeed, greaterThan(originalSpeed));
        expect(driver.smoothingFactor, equals(0.35));
      });

      test('should reset to normal rotation correctly', () {
        const driverId = 'test_driver_11';
        
        AnimationManager.initializeDriver(driverId);
        
        // Set faster rotation first
        AnimationManager.setFasterRotation(driverId);
        
        // Reset to normal
        AnimationManager.setNormalRotation(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        
        expect(driver.animationSpeed, equals(AnimationConstants.mediumAnimationSpeed));
        expect(driver.smoothingFactor, equals(AnimationConstants.smoothingFactor));
      });

      test('should clamp animation speed to valid range', () {
        const driverId = 'test_driver_12';
        
        AnimationManager.initializeDriver(driverId);
        
        // Test extreme multiplier
        AnimationManager.setFasterRotation(driverId, speedMultiplier: 100.0);
        final driver = AnimationManager.getDriver(driverId)!;
        
        expect(driver.animationSpeed, lessThanOrEqualTo(0.8));
        expect(driver.animationSpeed, greaterThanOrEqualTo(0.05));
      });
    });

    group('Target Change Intervals', () {
      test('should set target change interval correctly', () {
        const driverId = 'test_driver_13';
        const testInterval = 150;
        
        AnimationManager.initializeDriver(driverId);
        AnimationManager.setTargetChangeInterval(driverId, testInterval);
        
        final driver = AnimationManager.getDriver(driverId)!;
        expect(driver.targetChangeInterval, equals(testInterval));
      });

      test('should clamp target change interval to valid range', () {
        const driverId = 'test_driver_14';
        
        AnimationManager.initializeDriver(driverId);
        
        // Test minimum clamp
        AnimationManager.setTargetChangeInterval(driverId, 5);
        expect(AnimationManager.getDriver(driverId)!.targetChangeInterval, equals(20));
        
        // Test maximum clamp
        AnimationManager.setTargetChangeInterval(driverId, 500);
        expect(AnimationManager.getDriver(driverId)!.targetChangeInterval, equals(300));
      });

      test('should detect when target should change', () {
        const driverId = 'test_driver_15';
        
        AnimationManager.initializeDriver(driverId);
        final driver = AnimationManager.getDriver(driverId)!;
        
        // Set short interval for testing
        driver.targetChangeInterval = 5;
        driver.lastTargetChange = 0;
        driver.animationTicks = 0;
        
        // Should not change initially
        expect(driver.shouldChangeTarget(), isFalse);
        
        // Advance ticks
        driver.animationTicks = 6;
        expect(driver.shouldChangeTarget(), isTrue);
        
        // Mark changed and test again
        driver.markTargetChanged();
        expect(driver.shouldChangeTarget(), isFalse);
      });
    });

    group('Animation Calculation Utilities', () {
      test('should calculate smoothed angles correctly', () {
        const currentAngle = 0.0;
        const targetAngle = 90.0;
        const smoothingFactor = 0.25;
        
        final smoothedAngle = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: smoothingFactor,
        );
        
        // Should be between current and target
        expect(smoothedAngle, greaterThan(currentAngle));
        expect(smoothedAngle, lessThan(targetAngle));
        
        // Should be exactly 25% of the way to target
        expect(smoothedAngle, closeTo(22.5, 0.1));
      });

      test('should normalize angles correctly', () {
        expect(AnimationCalculator.normalizeAngle(370.0), closeTo(10.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(-190.0), closeTo(170.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(180.0), closeTo(180.0, 0.1));
        expect(AnimationCalculator.normalizeAngle(0.0), closeTo(0.0, 0.1));
      });

      test('should calculate angle differences correctly', () {
        expect(
          AnimationCalculator.calculateAngleDifference(
            currentAngle: 10.0,
            targetAngle: 50.0,
          ),
          closeTo(40.0, 0.1),
        );
        expect(
          AnimationCalculator.calculateAngleDifference(
            currentAngle: 350.0,
            targetAngle: 10.0,
          ),
          closeTo(20.0, 0.1),
        );
        expect(
          AnimationCalculator.calculateAngleDifference(
            currentAngle: 10.0,
            targetAngle: 350.0,
          ),
          closeTo(-20.0, 0.1),
        );
      });

      test('should generate valid random targets for all types', () {
        final random = Random(42); // Fixed seed for reproducible tests
        
        for (final targetType in RotationTarget.values) {
          final target = AnimationCalculator.generateRandomTarget(
            targetType: targetType,
            maxAngle: AnimationConstants.maxRotationAngle,
            random: random,
          );
          
          expect(
            target.abs(),
            lessThanOrEqualTo(AnimationConstants.maxRotationAngle),
          );
          
          // Verify target type behavior
          switch (targetType) {
            case RotationTarget.maximum:
              expect(target.abs(), greaterThan(90.0));
              break;
            case RotationTarget.minimum:
              expect(target.abs(), lessThan(90.0));
              break;
            case RotationTarget.center:
              expect(target.abs(), lessThan(45.0));
              break;
            case RotationTarget.random:
              // Random can be anything within range
              break;
          }
        }
      });
    });

    group('Driver Animation Model', () {
      test('should create driver model with correct defaults', () {
        const driverId = 'test_model_1';
        
        final driver = DriverAnimationModel(driverId: driverId);
        
        expect(driver.driverId, equals(driverId));
        expect(driver.currentAngle, equals(0.0));
        expect(driver.targetAngle, equals(0.0));
        expect(driver.shouldAnimate, isFalse);
        expect(driver.animationSpeed, equals(0.18));
        expect(driver.smoothingFactor, equals(0.25));
        expect(driver.animationTicks, equals(0));
        expect(driver.targetChangeInterval, equals(100));
      });

      test('should provide comprehensive debug information', () {
        const driverId = 'test_model_2';
        
        final driver = DriverAnimationModel(
          driverId: driverId,
          currentAngle: 45.5,
          targetAngle: 90.25,
          shouldAnimate: true,
          animationSpeed: 0.123,
        );
        
        final debugMap = driver.toDebugMap();
        
        expect(debugMap['driverId'], equals(driverId));
        expect(debugMap['currentAngle'], equals('45.50'));
        expect(debugMap['targetAngle'], equals('90.25'));
        expect(debugMap['shouldAnimate'], isTrue);
        expect(debugMap['speed'], equals('0.123'));
        expect(debugMap.containsKey('ticks'), isTrue);
        expect(debugMap.containsKey('targetType'), isTrue);
      });
    });

    group('Cleanup and Resource Management', () {
      test('should clean up all resources on stop', () {
        const driverId1 = 'cleanup_test_1';
        const driverId2 = 'cleanup_test_2';
        
        // Initialize and start multiple drivers
        AnimationManager.initializeDriver(driverId1);
        AnimationManager.initializeDriver(driverId2);
        
        AnimationManager.getDriver(driverId1)!.shouldAnimate = true;
        AnimationManager.getDriver(driverId2)!.shouldAnimate = true;
        
        AnimationManager.startDriverAnimation(driverId1, () {});
        AnimationManager.startDriverAnimation(driverId2, () {});
        
        expect(AnimationManager.getActiveAnimations().length, equals(2));
        
        // Stop all animations
        AnimationManager.stopAllAnimations();
        
        expect(AnimationManager.getActiveAnimations().isEmpty, isTrue);
        expect(AnimationManager.getAllDrivers().isEmpty, isTrue);
      });

      test('should handle non-existent driver operations gracefully', () {
        const nonExistentId = 'non_existent_driver';
        
        // These should not throw exceptions
        expect(AnimationManager.getCurrentRotationAngle(nonExistentId), equals(0.0));
        expect(AnimationManager.shouldDriverAnimate(nonExistentId), isFalse);
        expect(AnimationManager.isAnimationActive(nonExistentId), isFalse);
        expect(AnimationManager.getDriver(nonExistentId), isNull);
        
        // These should handle null gracefully
        AnimationManager.stopDriverAnimation(nonExistentId);
        AnimationManager.setFasterRotation(nonExistentId);
        AnimationManager.setNormalRotation(nonExistentId);
        AnimationManager.setRotationTarget(nonExistentId, RotationTarget.center);
      });
    });

    group('Integration with Constants', () {
      test('should use correct animation constants', () {
        expect(AnimationConstants.animationDuration, equals(const Duration(milliseconds: 100)));
        expect(AnimationConstants.maxRotationAngle, equals(180.0));
        expect(AnimationConstants.animationProbability, equals(20));
        expect(AnimationConstants.smoothingFactor, equals(0.25));
        expect(AnimationConstants.minAnimationSpeed, greaterThan(0.0));
        expect(AnimationConstants.maxAnimationSpeed, greaterThan(AnimationConstants.minAnimationSpeed));
        expect(AnimationConstants.mediumAnimationSpeed, 
               greaterThan(AnimationConstants.minAnimationSpeed));
        expect(AnimationConstants.mediumAnimationSpeed, 
               lessThan(AnimationConstants.maxAnimationSpeed));
      });

      test('should have valid car assets configuration', () {
        expect(AnimationConstants.defaultCarsAssets, isNotEmpty);
        expect(AnimationConstants.defaultCarsAssets.containsKey('taxi'), isTrue);
        expect(AnimationConstants.defaultCarsAssets.containsKey('luxury'), isTrue);
        expect(AnimationConstants.defaultCarsAssets.containsKey('suv'), isTrue);
        expect(AnimationConstants.defaultCarsAssets.containsKey('mini'), isTrue);
        expect(AnimationConstants.defaultCarsAssets.containsKey('bike'), isTrue);
        
        // Each car type should have at least one asset
        for (final assets in AnimationConstants.defaultCarsAssets.values) {
          expect(assets, isNotEmpty);
          expect(assets.first, contains('.png'));
        }
      });
    });
  });
}