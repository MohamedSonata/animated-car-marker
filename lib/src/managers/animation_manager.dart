import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/driver_animation_model.dart';
import '../models/rotation_target.dart';
import '../utils/logger.dart';
import '../utils/animation_calculator.dart';
import '../constants/animation_constants.dart';

/// Manager class responsible for core animation logic
///
/// This class handles all animation-related operations including:
/// - Starting and stopping driver animations
/// - Managing animation timers
/// - Updating animation ticks and target changes
/// - Calculating smooth rotation interpolation
/// - Managing animation state and performance
class AnimationManager {
  static final Map<String, Timer> _animationTimers = {};
  static final Map<String, DriverAnimationModel> _drivers = {};
  static Timer? _reassignAnimationsTimer;
  static bool _reassignAnimationsTimerActive = false;
  // Removed unused _timerTicks field

  /// Start animation for a specific driver
  ///
  /// [driverId] - The unique identifier for the driver
  /// [onUpdateMarker] - Callback function to update the marker on the map
  ///
  /// This method starts a periodic timer that updates the driver's rotation
  /// angle smoothly towards the target angle. It handles target changes,
  /// smooth interpolation, and animation state management.
  static void startDriverAnimation(
    String driverId,
    VoidCallback onUpdateMarker,
  ) {
    final driver = _drivers[driverId];
    if (driver == null ||
        (!driver.shouldAnimate &&
            !_reassignAnimationsTimerActive &&
            _reassignAnimationsTimer == null)) {
      Logger.debug("start::: reassignAnimationStatusTimer.");
      _reassignAnimationsTimer = Timer.periodic(const Duration(seconds: 10), (
        timer,
      ) {
        final currentDriver = _drivers[driverId];
        if (currentDriver == null || !currentDriver.shouldAnimate) {
          Logger.debug("reassignAnimationStatus");
          _reassignAnimationStatus();
          startDriverAnimation(driverId, onUpdateMarker);
        } else {
          _reassignAnimationStatus();
          Logger.debug("reassignAnimationStatus ELse");
        }
      });
      _reassignAnimationsTimerActive = true;
      Logger.debug("Driver $driverId not set to animate");
      return; // Don't animate this car
    }

    // Stop existing animation
    stopDriverAnimation(driverId);

    // Initialize if needed
    _initializeDriverIfNeeded(driverId);

    _animationTimers[driverId] = Timer.periodic(
      AnimationConstants.animationDuration,
      (timer) {
        final currentDriver = _drivers[driverId];
        if (currentDriver == null) return;

        updateAnimationTick(currentDriver);

        // Check if it's time to change target
        if (currentDriver.shouldChangeTarget()) {
          setNewRotationTarget(currentDriver);
          currentDriver.markTargetChanged();
        }

        // Smoothly interpolate current angle towards target angle
        final currentAngle = currentDriver.currentAngle;
        final targetAngle = currentDriver.targetAngle;

        // Apply smooth interpolation using driver-specific smoothing factor
        final smoothedAngle = AnimationCalculator.calculateSmoothedAngle(
          currentAngle: currentAngle,
          targetAngle: targetAngle,
          smoothingFactor: currentDriver.smoothingFactor,
        );
        currentDriver.currentAngle = smoothedAngle;

        // Debug print (reduce frequency to avoid spam)
        if (currentDriver.animationTicks % 20 == 0) {
          Logger.debug(
            "Driver $driverId: Current: ${currentAngle.toStringAsFixed(1)}° → Target: ${targetAngle.toStringAsFixed(1)}° (${currentDriver.currentTargetType.name}) → Smoothed: ${smoothedAngle.toStringAsFixed(1)}°",
          );
        }

        // Update marker
        onUpdateMarker.call();
      },
    );
  }

  /// Stop animation for a specific driver
  ///
  /// [driverId] - The unique identifier for the driver
  ///
  /// This method cancels the animation timer for the specified driver
  /// and removes it from the active timers map.
  static void stopDriverAnimation(String driverId) {
    _animationTimers[driverId]?.cancel();
    _animationTimers.remove(driverId);
  }

  /// Update animation tick for a driver
  ///
  /// [driver] - The driver animation model to update
  ///
  /// This method increments the animation tick counter for the driver.
  /// The tick counter is used to determine when to change rotation targets.
  static void updateAnimationTick(DriverAnimationModel? driver) {
    driver!.animationTicks++;
  }

  /// Set new rotation target for a driver
  ///
  /// [driver] - The driver animation model to update
  ///
  /// This method calculates and sets a new rotation target for the driver
  /// based on the current target type (maximum, minimum, center, or random).
  static void setNewRotationTarget(DriverAnimationModel? driver) {
    final random = math.Random();

    // Choose random target type
    final targetTypes = RotationTarget.values;
    driver!.currentTargetType = targetTypes[random.nextInt(targetTypes.length)];

    // Calculate target angle based on type
    driver.targetAngle = AnimationCalculator.generateRandomTarget(
      targetType: driver.currentTargetType,
      maxAngle: AnimationConstants.maxRotationAngle,
      random: random,
    );

    // Add some randomness to make it more natural
    final randomOffset = (random.nextDouble() - 0.5) * 10; // ±5 degrees
    driver.targetAngle = (driver.targetAngle + randomOffset).clamp(
      -AnimationConstants.maxRotationAngle,
      AnimationConstants.maxRotationAngle,
    );

    Logger.debug(
      'Driver ${driver.driverId}: New target ${driver.currentTargetType.name} = ${driver.targetAngle.toStringAsFixed(1)}°',
    );
  }

  /// Initialize driver if not already initialized
  ///
  /// [driverId] - The unique identifier for the driver
  ///
  /// This method creates a new driver animation model if one doesn't exist
  /// and initializes it with random animation properties.
  static void _initializeDriverIfNeeded(String driverId) {
    if (!_drivers.containsKey(driverId)) {
      final random = math.Random();

      // Create new driver model
      final driver = DriverAnimationModel(
        driverId: driverId,
        shouldAnimate:
            random.nextInt(100) < AnimationConstants.animationProbability,
        targetChangeInterval:
            80 + random.nextInt(40), // 80-120 ticks (8-12 seconds)
      );

      // Initialize random animation properties
      _initializeAnimationProperties(driver, random);

      // Set initial target
      setNewRotationTarget(driver);

      _drivers[driverId] = driver;

      Logger.info(
        "Initializing driver $driverId - should animate: ${driver.shouldAnimate}",
      );

      if (driver.shouldAnimate) {
        Logger.debug(
          'Driver $driverId selected for animation with speed: ${driver.animationSpeed}, pattern: ${driver.animationPattern}, target: ${driver.currentTargetType.name}',
        );
      }
    }
  }

  /// Initialize random animation properties for each driver
  ///
  /// [driver] - The driver animation model to initialize
  /// [random] - Random number generator for consistent randomization
  ///
  /// This method sets up random animation properties including speed,
  /// pattern, and smoothing factor for the driver.
  static void _initializeAnimationProperties(
    DriverAnimationModel driver,
    math.Random random,
  ) {
    // Random animation speed (slow, medium, fast) - Enhanced for faster rotation
    final speedType = random.nextInt(3);
    switch (speedType) {
      case 0: // Slow but still faster than before
        driver.animationSpeed =
            AnimationConstants.minAnimationSpeed + random.nextDouble() * 0.05;
        break;
      case 1: // Medium - noticeably faster
        driver.animationSpeed =
            AnimationConstants.mediumAnimationSpeed +
            random.nextDouble() * 0.08;
        break;
      case 2: // Fast - much more dynamic
        driver.animationSpeed =
            AnimationConstants.maxAnimationSpeed + random.nextDouble() * 0.15;
        break;
    }

    // Random animation pattern
    driver.animationPattern =
        AnimationConstants.animationPatternsList[random.nextInt(
          AnimationConstants.animationPatternsList.length,
        )];

    // Set smoothing factor based on speed (faster cars need higher smoothing)
    driver.smoothingFactor =
        AnimationConstants.smoothingFactor + (driver.animationSpeed * 0.5);
    driver.smoothingFactor = driver.smoothingFactor.clamp(0.15, 0.45);
  }

  /// Reassign animation status for all drivers
  ///
  /// This method randomly reassigns which drivers should animate.
  /// It's useful for dynamic updates and keeping animations varied.
  static void _reassignAnimationStatus() {
    final random = math.Random();
    for (String driverId in _drivers.keys.toList()) {
      final driver = _drivers[driverId]!;
      driver.shouldAnimate =
          random.nextInt(100) < AnimationConstants.animationProbability;
      // Reinitialize animation properties for active drivers
      if (driver.shouldAnimate) {
        _initializeAnimationProperties(driver, random);
        setNewRotationTarget(driver);
      }
    }
  }

  /// Stop all animations and clean up timers
  ///
  /// This method cancels all active animation timers and clears
  /// the drivers and timers maps. It also stops the reassign timer.
  static void stopAllAnimations() {
    for (Timer timer in _animationTimers.values) {
      timer.cancel();
    }
    _reassignAnimationsTimer?.cancel();
    _animationTimers.clear();
    _drivers.clear();
    _reassignAnimationsTimerActive = false;
  }

  /// Pause all animations
  ///
  /// This method cancels all active animation timers but keeps
  /// the driver data intact for later resumption.
  static void pauseAllAnimations() {
    for (final driverId in _animationTimers.keys.toList()) {
      _animationTimers[driverId]?.cancel();
    }
    _animationTimers.clear();
  }

  /// Resume animations for drivers that should animate
  ///
  /// [onUpdateMarker] - Callback function to update markers on the map
  ///
  /// This method restarts animations for all drivers that are
  /// marked as should animate.
  static void resumeAllAnimations(VoidCallback onUpdateMarker) {
    final List<String> driversToResume = [];

    for (final driverId in _drivers.keys) {
      if (_drivers[driverId]!.shouldAnimate) {
        driversToResume.add(driverId);
      }
    }

    for (final driverId in driversToResume) {
      startDriverAnimation(driverId, onUpdateMarker);
    }
  }

  /// Check if animation is active for a driver
  ///
  /// [driverId] - The unique identifier for the driver
  /// Returns true if the driver has an active animation timer
  static bool isAnimationActive(String driverId) {
    return _animationTimers.containsKey(driverId);
  }

  /// Get all active animation driver IDs
  ///
  /// Returns a list of driver IDs that currently have active animations
  static List<String> getActiveAnimations() {
    return _animationTimers.keys.toList();
  }

  /// Get driver animation model
  ///
  /// [driverId] - The unique identifier for the driver
  /// Returns the driver animation model or null if not found
  static DriverAnimationModel? getDriver(String driverId) {
    return _drivers[driverId];
  }

  /// Get all drivers
  ///
  /// Returns a copy of all driver animation models
  static Map<String, DriverAnimationModel> getAllDrivers() {
    return Map.from(_drivers);
  }

  /// Initialize a driver with animation decision
  ///
  /// [driverId] - The unique identifier for the driver
  ///
  /// This method creates and initializes a driver if it doesn't exist.
  /// It's a public interface for driver initialization.
  static void initializeDriver(String driverId) {
    _initializeDriverIfNeeded(driverId);
  }

  /// Set faster rotation speed for specific driver
  ///
  /// [driverId] - The unique identifier for the driver
  /// [speedMultiplier] - Multiplier for the current speed (default: 2.0)
  ///
  /// This method increases the animation speed for a specific driver
  /// while maintaining smooth animation characteristics.
  static void setFasterRotation(
    String driverId, {
    double speedMultiplier = 2.0,
  }) {
    final driver = _drivers[driverId];
    if (driver != null) {
      final currentSpeed = driver.animationSpeed;
      driver.animationSpeed = (currentSpeed * speedMultiplier).clamp(0.05, 0.8);

      // Adjust smoothing for faster rotation while keeping it smooth
      driver.smoothingFactor = 0.35; // Higher for faster response

      Logger.debug(
        'Driver $driverId speed increased to: ${driver.animationSpeed}',
      );
    }
  }

  /// Reset to normal rotation speed
  ///
  /// [driverId] - The unique identifier for the driver
  ///
  /// This method resets the animation speed and smoothing factor
  /// to default values for the specified driver.
  static void setNormalRotation(String driverId) {
    final driver = _drivers[driverId];
    if (driver != null) {
      // Reset to medium speed
      driver.animationSpeed = AnimationConstants.mediumAnimationSpeed;
      driver.smoothingFactor = AnimationConstants.smoothingFactor;

      Logger.debug(
        'Driver $driverId speed reset to normal: ${driver.animationSpeed}',
      );
    }
  }

  /// Force specific rotation target for a driver
  ///
  /// [driverId] - The unique identifier for the driver
  /// [targetType] - The rotation target type to set
  ///
  /// This method forces a specific rotation target type for a driver
  /// and immediately calculates the new target angle.
  static void setRotationTarget(String driverId, RotationTarget targetType) {
    final driver = _drivers[driverId];
    if (driver != null) {
      final random = math.Random();
      driver.currentTargetType = targetType;
      driver.targetAngle = AnimationCalculator.generateRandomTarget(
        targetType: targetType,
        maxAngle: AnimationConstants.maxRotationAngle,
        random: random,
      );

      // Add some randomness to make it more natural
      final randomOffset = (random.nextDouble() - 0.5) * 10; // ±5 degrees
      driver.targetAngle = (driver.targetAngle + randomOffset).clamp(
        -AnimationConstants.maxRotationAngle,
        AnimationConstants.maxRotationAngle,
      );

      driver.markTargetChanged(); // Reset the timer

      Logger.debug(
        'Driver $driverId: Forced target to ${targetType.name} = ${driver.targetAngle.toStringAsFixed(1)}°',
      );
    }
  }

  /// Set custom target change interval for a driver
  ///
  /// [driverId] - The unique identifier for the driver
  /// [intervalTicks] - The number of ticks between target changes
  ///
  /// This method sets how often the driver should change rotation targets.
  static void setTargetChangeInterval(String driverId, int intervalTicks) {
    final driver = _drivers[driverId];
    if (driver != null) {
      driver.targetChangeInterval = intervalTicks.clamp(
        20,
        300,
      ); // 2-30 seconds
      Logger.debug(
        'Driver $driverId: Target change interval set to $intervalTicks ticks',
      );
    }
  }

  /// Manually set rotation angle for a driver
  ///
  /// [driverId] - The unique identifier for the driver
  /// [angle] - The angle to set (will be clamped to valid range)
  ///
  /// This method directly sets the current and target rotation angles
  /// for a driver. Useful for testing or specific scenarios.
  static void setRotationAngle(String driverId, double angle) {
    final driver = _drivers[driverId];
    if (driver != null) {
      driver.currentAngle = angle.clamp(
        -AnimationConstants.maxRotationAngle,
        AnimationConstants.maxRotationAngle,
      );
      driver.targetAngle = driver.currentAngle;
    }
  }

  /// Get current rotation angle for a driver
  ///
  /// [driverId] - The unique identifier for the driver
  /// Returns the current rotation angle or 0.0 if driver not found
  static double getCurrentRotationAngle(String driverId) {
    return _drivers[driverId]?.currentAngle ?? 0.0;
  }

  /// Check if driver should animate
  ///
  /// [driverId] - The unique identifier for the driver
  /// Returns true if the driver is set to animate
  static bool shouldDriverAnimate(String driverId) {
    return _drivers[driverId]?.shouldAnimate ?? false;
  }

  /// Get all drivers that should animate
  ///
  /// Returns a list of driver IDs that are marked to animate
  static List<String> getAnimatableDrivers() {
    return _drivers.entries
        .where((entry) => entry.value.shouldAnimate)
        .map((entry) => entry.key)
        .toList();
  }
}
