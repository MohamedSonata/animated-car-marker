import 'dart:math' as math;
import '../models/rotation_target.dart';

/// Utility class for animation-related mathematical calculations
///
/// This class provides static methods for performing various mathematical
/// operations required for smooth car marker animations. All methods are
/// stateless and can be called independently.
///
/// The calculations include:
/// - Angle interpolation and smoothing
/// - Angle normalization and difference calculations
/// - Target angle generation based on rotation patterns
/// - Mathematical utilities for animation timing
///
/// Example usage:
/// ```dart
/// // Smooth angle interpolation
/// final smoothedAngle = AnimationCalculator.calculateSmoothedAngle(
///   currentAngle: 45.0,
///   targetAngle: 90.0,
///   smoothingFactor: 0.25,
/// );
///
/// // Calculate shortest angle difference
/// final angleDiff = AnimationCalculator.calculateAngleDifference(
///   currentAngle: 350.0,
///   targetAngle: 10.0,
/// );
///
/// // Generate random target angle
/// final randomTarget = AnimationCalculator.generateRandomTarget(
///   targetType: RotationTarget.random,
///   maxAngle: 180.0,
///   random: Random(),
/// );
/// ```
class AnimationCalculator {
  // Private constructor to prevent instantiation
  AnimationCalculator._();

  /// Calculate smoothed angle using linear interpolation
  ///
  /// Performs smooth interpolation between the current angle and target angle
  /// using the specified smoothing factor. This creates fluid animation
  /// transitions by gradually moving the current angle towards the target.
  ///
  /// The calculation handles 360° wrap-around to ensure the shortest rotation
  /// path is always taken, preventing unnecessary full rotations.
  ///
  /// Parameters:
  /// - [currentAngle]: The current rotation angle in degrees
  /// - [targetAngle]: The desired target angle in degrees
  /// - [smoothingFactor]: Interpolation factor (0.01 = very smooth, 1.0 = instant)
  ///
  /// Returns the new smoothed angle that should be applied to the marker.
  ///
  /// Example:
  /// ```dart
  /// // Smooth transition from 45° to 90° with 25% interpolation
  /// final smoothed = AnimationCalculator.calculateSmoothedAngle(
  ///   currentAngle: 45.0,
  ///   targetAngle: 90.0,
  ///   smoothingFactor: 0.25,
  /// );
  /// // Result: 56.25° (45 + (45 * 0.25))
  /// ```
  static double calculateSmoothedAngle({
    required double currentAngle,
    required double targetAngle,
    required double smoothingFactor,
  }) {
    // Calculate the shortest path between angles (handling 360° wrap-around)
    final angleDifference = calculateAngleDifference(
      currentAngle: currentAngle,
      targetAngle: targetAngle,
    );

    // Apply smooth interpolation using the smoothing factor
    return currentAngle + (angleDifference * smoothingFactor);
  }

  /// Calculate the shortest angle difference between two angles
  ///
  /// Determines the shortest rotational path between two angles, taking into
  /// account the 360° wrap-around. This ensures that rotations always take
  /// the most efficient path (e.g., from 350° to 10° goes +20° instead of -340°).
  ///
  /// Parameters:
  /// - [currentAngle]: The starting angle in degrees
  /// - [targetAngle]: The ending angle in degrees
  ///
  /// Returns the shortest angle difference, positive for clockwise rotation,
  /// negative for counter-clockwise rotation.
  ///
  /// Example:
  /// ```dart
  /// // Short path from 350° to 10°
  /// final diff1 = AnimationCalculator.calculateAngleDifference(
  ///   currentAngle: 350.0,
  ///   targetAngle: 10.0,
  /// );
  /// // Result: 20.0 (clockwise)
  ///
  /// // Short path from 10° to 350°
  /// final diff2 = AnimationCalculator.calculateAngleDifference(
  ///   currentAngle: 10.0,
  ///   targetAngle: 350.0,
  /// );
  /// // Result: -20.0 (counter-clockwise)
  /// ```
  static double calculateAngleDifference({
    required double currentAngle,
    required double targetAngle,
  }) {
    double angleDiff = targetAngle - currentAngle;

    // Normalize to shortest path (-180° to +180°)
    if (angleDiff > 180) {
      angleDiff -= 360;
    } else if (angleDiff < -180) {
      angleDiff += 360;
    }

    return angleDiff;
  }

  /// Normalize an angle to the range [0°, 360°)
  ///
  /// Ensures that any angle value is converted to the standard 0-360 degree
  /// range. This is useful for consistent angle representation and calculations.
  ///
  /// Parameters:
  /// - [angle]: The angle to normalize in degrees
  ///
  /// Returns the normalized angle in the range [0°, 360°).
  ///
  /// Example:
  /// ```dart
  /// final normalized1 = AnimationCalculator.normalizeAngle(450.0);
  /// // Result: 90.0
  ///
  /// final normalized2 = AnimationCalculator.normalizeAngle(-30.0);
  /// // Result: 330.0
  /// ```
  static double normalizeAngle(double angle) {
    angle = angle % 360;
    if (angle < 0) {
      angle += 360;
    }
    return angle;
  }

  /// Generate a target angle based on the specified rotation target type
  ///
  /// Creates appropriate target angles for different animation patterns.
  /// Each target type produces different movement behaviors to create
  /// varied and realistic car animations.
  ///
  /// Parameters:
  /// - [targetType]: The type of rotation target to generate
  /// - [maxAngle]: Maximum rotation angle from center (typically 180°)
  /// - [random]: Random number generator for randomized targets
  ///
  /// Returns the calculated target angle in degrees, clamped to the
  /// specified maximum angle range.
  ///
  /// Target types:
  /// - [RotationTarget.maximum]: Full rotation to maximum angle (±maxAngle)
  /// - [RotationTarget.minimum]: Small rotation (10% of maxAngle)
  /// - [RotationTarget.center]: Return to center position (0°)
  /// - [RotationTarget.random]: Random angle within 70% of maxAngle range
  ///
  /// Example:
  /// ```dart
  /// final random = Random();
  ///
  /// // Generate maximum rotation target
  /// final maxTarget = AnimationCalculator.generateRandomTarget(
  ///   targetType: RotationTarget.maximum,
  ///   maxAngle: 180.0,
  ///   random: random,
  /// );
  /// // Result: ±180.0 (randomly positive or negative)
  ///
  /// // Generate random target within range
  /// final randomTarget = AnimationCalculator.generateRandomTarget(
  ///   targetType: RotationTarget.random,
  ///   maxAngle: 180.0,
  ///   random: random,
  /// );
  /// // Result: Random angle between -126.0 and +126.0 (70% of ±180°)
  /// ```
  static double generateRandomTarget({
    required RotationTarget targetType,
    required double maxAngle,
    required math.Random random,
  }) {
    double targetAngle;

    switch (targetType) {
      case RotationTarget.maximum:
        // Full rotation to maximum angle (randomly positive or negative)
        targetAngle = maxAngle * (random.nextBool() ? 1 : -1);
        break;

      case RotationTarget.minimum:
        // Small rotation (10% of maximum angle)
        targetAngle = (maxAngle * 0.1) * (random.nextBool() ? 1 : -1);
        break;

      case RotationTarget.center:
        // Return to center position
        targetAngle = 0.0;
        break;

      case RotationTarget.random:
        // Random angle within 70% of the maximum range for natural movement
        targetAngle = (random.nextDouble() - 0.5) * 2 * maxAngle * 0.7;
        break;
    }

    // Add small random offset for more natural movement (±5 degrees)
    final randomOffset = (random.nextDouble() - 0.5) * 10;
    targetAngle += randomOffset;

    // Clamp to maximum angle range
    return targetAngle.clamp(-maxAngle, maxAngle);
  }

  /// Calculate animation speed based on pattern and randomization
  ///
  /// Generates appropriate animation speeds for different movement patterns.
  /// This creates variety in car animations by assigning different speeds
  /// based on the specified speed type.
  ///
  /// Parameters:
  /// - [speedType]: Speed category (0=slow, 1=medium, 2=fast)
  /// - [minSpeed]: Minimum animation speed value
  /// - [mediumSpeed]: Medium animation speed value
  /// - [maxSpeed]: Maximum animation speed value
  /// - [random]: Random number generator for speed variation
  ///
  /// Returns the calculated animation speed with random variation applied.
  ///
  /// Example:
  /// ```dart
  /// final random = Random();
  ///
  /// // Generate slow speed with variation
  /// final slowSpeed = AnimationCalculator.calculateAnimationSpeed(
  ///   speedType: 0,
  ///   minSpeed: 0.08,
  ///   mediumSpeed: 0.18,
  ///   maxSpeed: 0.35,
  ///   random: random,
  /// );
  /// // Result: 0.08 to 0.13 (minSpeed + random variation)
  /// ```
  static double calculateAnimationSpeed({
    required int speedType,
    required double minSpeed,
    required double mediumSpeed,
    required double maxSpeed,
    required math.Random random,
  }) {
    switch (speedType) {
      case 0: // Slow speed with slight variation
        return minSpeed + random.nextDouble() * 0.05;

      case 1: // Medium speed with moderate variation
        return mediumSpeed + random.nextDouble() * 0.08;

      case 2: // Fast speed with higher variation
        return maxSpeed + random.nextDouble() * 0.15;

      default:
        return mediumSpeed; // Default to medium speed
    }
  }

  /// Calculate smoothing factor based on animation speed
  ///
  /// Determines the appropriate smoothing factor for a given animation speed.
  /// Faster animations typically need higher smoothing factors to maintain
  /// responsiveness while preserving smooth movement.
  ///
  /// Parameters:
  /// - [animationSpeed]: The current animation speed
  /// - [baseSmoothingFactor]: Base smoothing factor to start from
  /// - [minSmoothingFactor]: Minimum allowed smoothing factor
  /// - [maxSmoothingFactor]: Maximum allowed smoothing factor
  ///
  /// Returns the calculated smoothing factor, clamped to the specified range.
  ///
  /// Example:
  /// ```dart
  /// final smoothing = AnimationCalculator.calculateSmoothingFactor(
  ///   animationSpeed: 0.35,
  ///   baseSmoothingFactor: 0.25,
  ///   minSmoothingFactor: 0.15,
  ///   maxSmoothingFactor: 0.45,
  /// );
  /// // Result: Higher smoothing factor for faster animation
  /// ```
  static double calculateSmoothingFactor({
    required double animationSpeed,
    required double baseSmoothingFactor,
    double minSmoothingFactor = 0.15,
    double maxSmoothingFactor = 0.45,
  }) {
    // Higher speed requires higher smoothing for responsiveness
    final calculatedSmoothingFactor =
        baseSmoothingFactor + (animationSpeed * 0.5);
    return calculatedSmoothingFactor.clamp(
      minSmoothingFactor,
      maxSmoothingFactor,
    );
  }

  /// Check if two angles are approximately equal within a tolerance
  ///
  /// Compares two angles considering floating-point precision and the
  /// circular nature of angles. Useful for determining when an animation
  /// has reached its target or for comparing angle values.
  ///
  /// Parameters:
  /// - [angle1]: First angle to compare in degrees
  /// - [angle2]: Second angle to compare in degrees
  /// - [tolerance]: Acceptable difference in degrees (default: 1.0°)
  ///
  /// Returns true if the angles are within the specified tolerance.
  ///
  /// Example:
  /// ```dart
  /// final isClose1 = AnimationCalculator.areAnglesEqual(
  ///   angle1: 359.5,
  ///   angle2: 0.5,
  ///   tolerance: 1.0,
  /// );
  /// // Result: true (angles are 1° apart considering wrap-around)
  ///
  /// final isClose2 = AnimationCalculator.areAnglesEqual(
  ///   angle1: 45.0,
  ///   angle2: 47.0,
  ///   tolerance: 1.0,
  /// );
  /// // Result: false (angles are 2° apart, exceeds tolerance)
  /// ```
  static bool areAnglesEqual({
    required double angle1,
    required double angle2,
    double tolerance = 1.0,
  }) {
    final difference = calculateAngleDifference(
      currentAngle: angle1,
      targetAngle: angle2,
    ).abs();
    return difference <= tolerance;
  }

  /// Convert degrees to radians
  ///
  /// Utility method for converting angle measurements from degrees to radians.
  /// Useful when interfacing with mathematical functions that require radians.
  ///
  /// Parameters:
  /// - [degrees]: Angle in degrees
  ///
  /// Returns the angle converted to radians.
  ///
  /// Example:
  /// ```dart
  /// final radians = AnimationCalculator.degreesToRadians(180.0);
  /// // Result: π (approximately 3.14159)
  /// ```
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Convert radians to degrees
  ///
  /// Utility method for converting angle measurements from radians to degrees.
  /// Useful when working with mathematical calculations that return radians.
  ///
  /// Parameters:
  /// - [radians]: Angle in radians
  ///
  /// Returns the angle converted to degrees.
  ///
  /// Example:
  /// ```dart
  /// final degrees = AnimationCalculator.radiansToDegrees(math.pi);
  /// // Result: 180.0
  /// ```
  static double radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }
}
