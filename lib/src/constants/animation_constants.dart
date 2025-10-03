/// Animation constants and configuration values for the Animated Car Marker package
///
/// This class contains all the static configuration values used throughout
/// the animation system. Centralizing these constants makes it easier to
/// maintain consistent behavior and allows for easy tuning of animation
/// parameters.
///
/// The constants are organized into logical groups:
/// - Timing constants for animation intervals and durations
/// - Angle constants for rotation limits and calculations
/// - Speed constants for different animation velocities
/// - Probability constants for random behavior
/// - Asset constants for car type definitions
///
/// Example usage:
/// ```dart
/// // Use timing constants
/// Timer.periodic(AnimationConstants.animationDuration, (timer) {
///   // Animation logic
/// });
///
/// // Use angle limits
/// final clampedAngle = angle.clamp(
///   -AnimationConstants.maxRotationAngle,
///   AnimationConstants.maxRotationAngle,
/// );
///
/// // Use speed constants
/// driver.animationSpeed = AnimationConstants.mediumAnimationSpeed;
/// ```
class AnimationConstants {
  // Private constructor to prevent instantiation
  AnimationConstants._();

  // ============================================================================
  // TIMING CONSTANTS
  // ============================================================================

  /// Duration between animation frame updates
  ///
  /// Set to 100ms for 10 FPS animation rate, providing smooth movement
  /// while maintaining good performance. Faster updates (shorter duration)
  /// create smoother animations but use more CPU resources.
  static const Duration animationDuration = Duration(milliseconds: 100);

  // ============================================================================
  // ANGLE CONSTANTS
  // ============================================================================

  /// Maximum rotation angle from center in degrees
  ///
  /// Defines the maximum angle a car marker can rotate from its neutral
  /// position. Set to 180° to allow full rotation range while maintaining
  /// realistic car movement appearance. Reduced from 360° for more natural
  /// looking traffic simulation.
  static const double maxRotationAngle = 180.0;

  // ============================================================================
  // PROBABILITY CONSTANTS
  // ============================================================================

  /// Probability percentage that a car will be selected for animation
  ///
  /// Set to 20% to ensure not all cars animate simultaneously, creating
  /// more realistic traffic patterns. Higher values create more active
  /// traffic but may impact performance with many markers.
  static const int animationProbability = 20;

  // ============================================================================
  // SMOOTHING CONSTANTS
  // ============================================================================

  /// Default smoothing factor for angle interpolation
  ///
  /// Controls how quickly the current angle approaches the target angle.
  /// Higher values (closer to 1.0) create more responsive but less smooth
  /// animations. Lower values create smoother but slower transitions.
  ///
  /// Range: 0.01 (very smooth) to 1.0 (instant)
  static const double smoothingFactor = 0.25;

  // ============================================================================
  // SPEED CONSTANTS
  // ============================================================================

  /// Minimum animation speed for slow car movements
  ///
  /// Used for cars that should rotate slowly and gently. Creates subtle
  /// movement that appears natural for cars in slow traffic or making
  /// minor directional adjustments.
  static const double minAnimationSpeed = 0.08;

  /// Maximum animation speed for fast car movements
  ///
  /// Used for cars that should rotate quickly and dynamically. Creates
  /// more dramatic movement suitable for cars making sharp turns or
  /// rapid lane changes.
  static const double maxAnimationSpeed = 0.35;

  /// Medium animation speed for balanced car movements
  ///
  /// The default speed that provides a good balance between smooth
  /// animation and responsive movement. Most suitable for general
  /// traffic simulation scenarios.
  static const double mediumAnimationSpeed = 0.18;

  // ============================================================================
  // PATTERN CONSTANTS
  // ============================================================================

  /// Available animation patterns for different movement behaviors
  ///
  /// Different patterns can be used to create varied animation behaviors:
  /// - Pattern 1: Standard rotation with regular target changes
  /// - Pattern 2: More frequent direction changes
  /// - Pattern 3: Slower, more deliberate movements
  /// - Pattern 4: Quick, sporadic movements
  ///
  /// These patterns add variety to the animation system and can be
  /// assigned randomly or based on car type/behavior requirements.
  static const List<int> animationPatternsList = [1, 2, 3, 4];

  // ============================================================================
  // CAR ASSET CONSTANTS (DEFAULT FALLBACK)
  // ============================================================================

  /// Default car asset paths (used as fallback when user doesn't provide custom assets)
  ///
  /// This provides a default set of car assets that can be used if the user
  /// doesn't specify their own custom assets. Users should provide their own
  /// assets through the AnimatedCarMarkerManager configuration.
  ///
  /// Note: These are fallback assets. Users should configure their own assets
  /// when initializing the AnimatedCarMarkerManager for better customization.
  ///
  /// Example of user-provided assets:
  /// ```dart
  /// final customAssets = {
  ///   'taxi': [CarAssetModel(assetPath: 'assets/my_taxi.png')],
  ///   'luxury': [CarAssetModel(assetPath: 'assets/my_luxury.png')],
  /// };
  /// ```
  static const Map<String, List<String>> defaultCarsAssets = {
    'taxi': ['assets/images/cars/car1-64.png'],
    'luxury': ['assets/images/cars/car1-64.png'],
    'suv': ['assets/images/cars/car1-64.png'],
    'mini': ['assets/images/cars/car1-64.png'],
    'bike': ['assets/images/cars/car1-64.png'],
  };

  // ============================================================================
  // INTERVAL CONSTANTS
  // ============================================================================

  /// Default interval for target changes in animation ticks
  ///
  /// Defines how many animation ticks should pass before a car changes
  /// its rotation target. At 10 FPS (100ms intervals), 100 ticks equals
  /// approximately 10 seconds, providing good variety without being
  /// too frequent or too static.
  static const int defaultTargetChangeInterval = 100;

  /// Minimum allowed target change interval in ticks
  ///
  /// Prevents targets from changing too frequently, which would create
  /// erratic, unrealistic movement. 20 ticks = ~2 seconds minimum.
  static const int minTargetChangeInterval = 20;

  /// Maximum allowed target change interval in ticks
  ///
  /// Prevents targets from remaining static for too long, ensuring
  /// cars continue to show some movement variety. 300 ticks = ~30 seconds.
  static const int maxTargetChangeInterval = 300;

  // ============================================================================
  // LIFECYCLE CONSTANTS
  // ============================================================================

  /// Interval for reassigning animation status in seconds
  ///
  /// How often the system should reassess which cars should be animating.
  /// This allows for dynamic changes in traffic patterns and ensures
  /// the animation probability is maintained over time.
  static const int reassignAnimationIntervalSeconds = 10;
}
