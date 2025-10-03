/// Enum for different rotation target types used in car marker animations
///
/// This enum defines the various types of rotation targets that can be used
/// to control how car markers animate their rotation on the map. Each target
/// type creates different movement patterns for more realistic and varied
/// car animations.
///
/// Example usage:
/// ```dart
/// // Set a car to rotate to maximum angle
/// final target = RotationTarget.maximum;
///
/// // Use in switch statement for target calculation
/// switch (target) {
///   case RotationTarget.maximum:
///     angle = maxRotationAngle;
///     break;
///   case RotationTarget.center:
///     angle = 0.0;
///     break;
///   // ... other cases
/// }
/// ```
enum RotationTarget {
  /// Rotate to the maximum allowed angle (positive or negative)
  ///
  /// This target type causes the car to rotate to the maximum rotation
  /// angle defined by the system, creating dramatic turning animations.
  /// The direction (positive or negative) is typically chosen randomly.
  maximum,

  /// Rotate to the minimum allowed angle (close to center)
  ///
  /// This target type causes subtle rotation movements, typically
  /// around 10% of the maximum angle. Creates gentle swaying or
  /// minor directional adjustments that appear natural.
  minimum,

  /// Rotate to a random angle within the allowed range
  ///
  /// This target type selects a random angle within the rotation
  /// limits, creating unpredictable and varied movement patterns.
  /// Most commonly used for realistic traffic simulation.
  random,

  /// Rotate to the center position (0 degrees)
  ///
  /// This target type causes the car to return to the neutral
  /// position with no rotation. Useful for resetting car orientation
  /// or creating straight-line movement appearance.
  center,
}
