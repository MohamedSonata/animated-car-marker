import 'rotation_target.dart';

/// Driver Animation Model for better organization and maintainability
///
/// This class represents the animation state and configuration for a single driver's
/// car marker on the map. It manages rotation angles, animation timing, and behavior
/// patterns to create smooth, realistic car movement animations.
///
/// Example usage:
/// ```dart
/// final driver = DriverAnimationModel(
///   driverId: 'driver123',
///   shouldAnimate: true,
///   animationSpeed: 0.18,
/// );
///
/// // Check if target should change
/// if (driver.shouldChangeTarget()) {
///   // Update target and mark change
///   driver.markTargetChanged();
/// }
///
/// // Get debug information
/// final debugInfo = driver.toDebugMap();
/// print('Driver stats: $debugInfo');
/// ```
class DriverAnimationModel {
  /// Unique identifier for the driver
  final String driverId;

  /// Current rotation angle of the car marker in degrees
  double currentAngle;

  /// Target rotation angle the car is animating towards in degrees
  double targetAngle;

  /// Next target angle for smoother transitions
  double nextTargetAngle;

  /// Whether this driver's car should animate or remain static
  bool shouldAnimate;

  /// Speed of the animation (higher values = faster rotation)
  /// Typical range: 0.08 (slow) to 0.35 (fast)
  double animationSpeed;

  /// Smoothing factor for angle interpolation (0.01 = very smooth, 1.0 = instant)
  /// Higher values create more responsive but less smooth animations
  double smoothingFactor;

  /// Animation pattern identifier for different movement behaviors
  int animationPattern;

  /// Number of animation ticks that have elapsed
  int animationTicks;

  /// How often to change target (in ticks) - controls animation variety
  /// Typical range: 80-120 ticks (8-12 seconds at 10 FPS)
  int targetChangeInterval;

  /// Tick count when the target was last changed
  int lastTargetChange;

  /// Current type of rotation target being used
  RotationTarget currentTargetType;

  /// Creates a new driver animation model with the specified configuration
  ///
  /// [driverId] - Unique identifier for this driver
  /// [currentAngle] - Initial rotation angle in degrees (default: 0.0)
  /// [targetAngle] - Initial target angle in degrees (default: 0.0)
  /// [nextTargetAngle] - Next target for smooth transitions (default: 0.0)
  /// [shouldAnimate] - Whether to animate this driver (default: false)
  /// [animationSpeed] - Speed of rotation animation (default: 0.18)
  /// [smoothingFactor] - Interpolation smoothness (default: 0.25)
  /// [animationPattern] - Pattern identifier (default: 1)
  /// [animationTicks] - Initial tick count (default: 0)
  /// [targetChangeInterval] - Ticks between target changes (default: 100)
  /// [lastTargetChange] - Last target change tick (default: 0)
  /// [currentTargetType] - Initial target type (default: RotationTarget.random)
  DriverAnimationModel({
    required this.driverId,
    this.currentAngle = 0.0,
    this.targetAngle = 0.0,
    this.nextTargetAngle = 0.0,
    this.shouldAnimate = false,
    this.animationSpeed = 0.18,
    this.smoothingFactor = 0.25,
    this.animationPattern = 1,
    this.animationTicks = 0,
    this.targetChangeInterval =
        100, // Change target every 100 ticks (~10 seconds)
    this.lastTargetChange = 0,
    this.currentTargetType = RotationTarget.random,
  });

  /// Check if it's time to change the rotation target
  ///
  /// Returns true when the elapsed ticks since the last target change
  /// exceed the configured target change interval.
  ///
  /// This method is used to create variety in the animation by periodically
  /// changing the target angle the car is rotating towards.
  bool shouldChangeTarget() {
    return (animationTicks - lastTargetChange) >= targetChangeInterval;
  }

  /// Mark that the target was changed and reset the change timer
  ///
  /// This should be called after setting a new target angle to reset
  /// the timing mechanism for the next target change.
  void markTargetChanged() {
    lastTargetChange = animationTicks;
  }

  /// Get comprehensive debug information about the animation state
  ///
  /// Returns a map containing all relevant animation parameters formatted
  /// for debugging and monitoring purposes. Angles are formatted to 2 decimal
  /// places and speeds to 3 decimal places for readability.
  ///
  /// The returned map includes:
  /// - driverId: The unique driver identifier
  /// - currentAngle: Current rotation angle (formatted)
  /// - targetAngle: Target rotation angle (formatted)
  /// - nextTargetAngle: Next target angle (formatted)
  /// - shouldAnimate: Animation enabled flag
  /// - speed: Animation speed (formatted)
  /// - smoothness: Smoothing factor (formatted)
  /// - pattern: Animation pattern identifier
  /// - ticks: Current animation tick count
  /// - targetType: Current target type name
  /// - ticksUntilChange: Remaining ticks until next target change
  Map<String, dynamic> toDebugMap() {
    return {
      'driverId': driverId,
      'currentAngle': currentAngle.toStringAsFixed(2),
      'targetAngle': targetAngle.toStringAsFixed(2),
      'nextTargetAngle': nextTargetAngle.toStringAsFixed(2),
      'shouldAnimate': shouldAnimate,
      'speed': animationSpeed.toStringAsFixed(3),
      'smoothness': smoothingFactor.toStringAsFixed(3),
      'pattern': animationPattern,
      'ticks': animationTicks,
      'targetType': currentTargetType.name,
      'ticksUntilChange':
          targetChangeInterval - (animationTicks - lastTargetChange),
    };
  }
}
