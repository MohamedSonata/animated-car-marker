import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'utils/logger.dart';
import 'managers/icon_manager.dart';
import 'managers/animation_manager.dart';
import 'managers/lifecycle_manager.dart';
import 'models/driver_animation_model.dart';
import 'models/rotation_target.dart';
import 'models/animated_car_config.dart';

/// Enhanced Animated Car Marker Manager with Smooth Rotation
///
/// This class provides a comprehensive API for managing animated car markers
/// on Google Maps. It handles icon loading, animation lifecycle, and provides
/// various customization options for smooth rotation animations.
///
/// ## Key Features
/// - Flexible asset configuration (user-provided or default assets)
/// - Automatic icon preloading and caching
/// - Smooth rotation animations with customizable parameters
/// - Lifecycle management (pause/resume/cleanup)
/// - Performance optimization for multiple markers
/// - Debugging and monitoring capabilities
///
/// ## Basic Usage with Default Assets
/// ```dart
/// // 1. Initialize with default configuration
/// await AnimatedCarMarkerManager.initialize();
///
/// // 2. Initialize a driver
/// AnimatedCarMarkerManager.initializeDriver('driver123');
///
/// // 3. Start animation
/// AnimatedCarMarkerManager.startAnimation('driver123', () {
///   // Update your map marker here
///   updateMarkerOnMap();
/// });
///
/// // 4. Get current rotation angle
/// final angle = AnimatedCarMarkerManager.getCurrentRotationAngle('driver123');
/// ```
///
/// ## Advanced Usage with Custom Assets
/// ```dart
/// // 1. Create custom configuration
/// final config = AnimatedCarConfig(
///   carAssets: {
///     'taxi': [CarAssetModel(assetPath: 'assets/my_taxi.png')],
///     'luxury': [CarAssetModel(assetPath: 'assets/my_luxury.png')],
///   },
///   iconSize: 50.0,
///   animationProbability: 30,
/// );
///
/// // 2. Initialize with custom configuration
/// await AnimatedCarMarkerManager.initialize(config: config);
///
/// // 3. Use custom smoothness and turbo mode
/// AnimatedCarMarkerManager.startAnimationWithSmoothness(
///   'driver123',
///   () => updateMarkerOnMap(),
///   customSmoothness: 0.15, // 0.01 = very smooth, 1.0 = instant
///   turboMode: true,
/// );
/// ```
class AnimatedCarMarkerManager {
  static bool _isInitialized = false;

  /// Initializes the AnimatedCarMarkerManager with configuration.
  ///
  /// This method must be called before using any other methods of the manager.
  /// It sets up the icon manager, animation system, and preloads assets.
  ///
  /// Parameters:
  /// - [config]: Optional configuration. If null, uses default configuration.
  ///
  /// Returns:
  /// A [Future] that completes when initialization is finished.
  ///
  /// Example:
  /// ```dart
  /// // Initialize with default configuration
  /// await AnimatedCarMarkerManager.initialize();
  ///
  /// // Initialize with custom configuration
  /// final config = AnimatedCarConfig(
  ///   carAssets: {
  ///     'taxi': [CarAssetModel(assetPath: 'assets/my_taxi.png')],
  ///   },
  ///   iconSize: 50.0,
  /// );
  /// await AnimatedCarMarkerManager.initialize(config: config);
  /// ```
  ///
  /// Throws:
  /// - [StateError] if already initialized
  /// - [ArgumentError] if configuration is invalid
  static Future<void> initialize({AnimatedCarConfig? config}) async {
    if (_isInitialized) {
      Logger.warning('AnimatedCarMarkerManager already initialized');
      return;
    }

    final effectiveConfig = config ?? AnimatedCarConfig.withDefaults();
    
    try {
      await IconManager.initialize(effectiveConfig);
      _isInitialized = true;
      Logger.info('AnimatedCarMarkerManager initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize AnimatedCarMarkerManager', e);
      rethrow;
    }
  }

  /// Preloads all car icons for different vehicle types.
  ///
  /// This method is automatically called during initialization if preloadIcons
  /// is enabled in the configuration. You can also call it manually to reload
  /// icons with a different size.
  ///
  /// Parameters:
  /// - [size]: The size of the icons in logical pixels (optional)
  ///
  /// Returns:
  /// A [Future] that completes when all icons are loaded and cached.
  ///
  /// Example:
  /// ```dart
  /// // Preload with configuration size
  /// await AnimatedCarMarkerManager.preloadCarIcons();
  ///
  /// // Preload with custom size
  /// await AnimatedCarMarkerManager.preloadCarIcons(size: 60.0);
  /// ```
  ///
  /// Throws:
  /// - [StateError] if manager is not initialized
  static Future<void> preloadCarIcons({double? size}) async {
    _ensureInitialized();
    return IconManager.preloadIcons(size: size);
  }

  /// Retrieves the cached icon for a specific car type.
  ///
  /// Returns a [BitmapDescriptor] for the specified car type. If the
  /// icon hasn't been loaded or fails to load, returns a fallback
  /// colored marker to ensure functionality.
  ///
  /// Parameters:
  /// - [carType]: The type of car (depends on your configuration)
  ///
  /// Returns:
  /// A [BitmapDescriptor] that can be used with Google Maps markers.
  ///
  /// Example:
  /// ```dart
  /// final taxiIcon = AnimatedCarMarkerManager.getCarIcon('taxi');
  /// final marker = Marker(
  ///   markerId: MarkerId('driver123'),
  ///   position: driverPosition,
  ///   icon: taxiIcon,
  /// );
  /// ```
  ///
  /// Throws:
  /// - [StateError] if manager is not initialized
  static BitmapDescriptor getCarIcon(String carType) {
    _ensureInitialized();
    return IconManager.getIcon(carType);
  }

  /// Ensures the manager is initialized before performing operations
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'AnimatedCarMarkerManager not initialized. Call initialize() first.'
      );
    }
  }

  /// Checks if the manager is initialized
  ///
  /// Returns true if the manager has been initialized and is ready to use.
  static bool get isInitialized => _isInitialized;

  /// Gets the current configuration
  ///
  /// Returns the current AnimatedCarConfig or null if not initialized.
  static AnimatedCarConfig? getCurrentConfig() {
    return IconManager.getCurrentConfig();
  }

  /// Initializes a driver for potential animation.
  ///
  /// This method creates a driver animation model and randomly determines
  /// whether the driver should have animated rotation. Not all drivers
  /// will be animated to maintain performance and visual balance.
  ///
  /// Parameters:
  /// - [driverId]: Unique identifier for the driver
  ///
  /// Example:
  /// ```dart
  /// AnimatedCarMarkerManager.initializeDriver('driver123');
  ///
  /// // Check if driver will animate
  /// if (AnimatedCarMarkerManager.shouldDriverAnimate('driver123')) {
  ///   // Start animation for this driver
  ///   AnimatedCarMarkerManager.startAnimation('driver123', updateCallback);
  /// }
  /// ```
  ///
  /// Note:
  /// This method should be called before starting any animations for a driver.
  /// The animation decision is made randomly based on configured probability.
  ///
  /// Throws:
  /// - [StateError] if manager is not initialized
  static void initializeDriver(String driverId) {
    _ensureInitialized();
    AnimationManager.initializeDriver(driverId);
  }

  /// Starts rotation animation for a specific driver.
  ///
  /// Begins smooth rotation animation for the specified driver if they
  /// are configured to animate. The animation runs at 10 FPS with
  /// smooth interpolation between rotation targets.
  ///
  /// Parameters:
  /// - [driverId]: Unique identifier for the driver
  /// - [onUpdateMarker]: Callback function called when marker should be updated
  ///
  /// Example:
  /// ```dart
  /// AnimatedCarMarkerManager.startAnimation('driver123', () {
  ///   final angle = AnimatedCarMarkerManager.getCurrentRotationAngle('driver123');
  ///   final icon = AnimatedCarMarkerManager.getCarIcon('taxi');
  ///
  ///   final updatedMarker = MarkerRotation.createRotatedMarker(
  ///     markerId: 'driver123',
  ///     position: driverPosition,
  ///     icon: icon,
  ///     rotation: angle,
  ///   );
  ///
  ///   // Update your map with the new marker
  ///   updateMapMarker(updatedMarker);
  /// });
  /// ```
  ///
  /// Note:
  /// The callback will be invoked approximately every 100ms while animation
  /// is active. Ensure the callback is efficient to maintain performance.
  static void startAnimation(String driverId, VoidCallback onUpdateMarker) {
    AnimationManager.startDriverAnimation(driverId, onUpdateMarker);
  }

  /// Retrieves the current rotation angle for a driver.
  ///
  /// Returns the current rotation angle in degrees for the specified driver.
  /// This value is continuously updated during animation and can be used
  /// to create rotated markers.
  ///
  /// Parameters:
  /// - [driverId]: Unique identifier for the driver
  ///
  /// Returns:
  /// The current rotation angle in degrees (0.0 to 360.0), or 0.0 if
  /// the driver is not found or not initialized.
  ///
  /// Example:
  /// ```dart
  /// final angle = AnimatedCarMarkerManager.getCurrentRotationAngle('driver123');
  /// print('Current rotation: ${angle.toStringAsFixed(1)}°');
  ///
  /// // Use angle to create rotated marker
  /// final marker = MarkerRotation.createRotatedMarker(
  ///   markerId: 'driver123',
  ///   position: position,
  ///   icon: icon,
  ///   rotation: angle,
  /// );
  /// ```
  static double getCurrentRotationAngle(String driverId) {
    return AnimationManager.getCurrentRotationAngle(driverId);
  }

  /// Stops animation for a specific driver.
  ///
  /// Halts the rotation animation for the specified driver and cleans up
  /// associated resources. The driver's current rotation angle is preserved.
  ///
  /// Parameters:
  /// - [driverId]: Unique identifier for the driver
  ///
  /// Example:
  /// ```dart
  /// // Stop animation when driver goes offline
  /// AnimatedCarMarkerManager.stopAnimation('driver123');
  ///
  /// // The marker will maintain its last rotation angle
  /// final finalAngle = AnimatedCarMarkerManager.getCurrentRotationAngle('driver123');
  /// ```
  static void stopAnimation(String driverId) {
    AnimationManager.stopDriverAnimation(driverId);
  }

  /// Stop all animations and clean up
  static void stopAllAnimations() {
    AnimationManager.stopAllAnimations();
  }

  /// Check if driver should animate
  static bool shouldDriverAnimate(String driverId) {
    return AnimationManager.shouldDriverAnimate(driverId);
  }

  /// Check if animation is active for driver
  static bool isAnimationActive(String driverId) {
    return AnimationManager.isAnimationActive(driverId);
  }

  /// Get all available car types
  ///
  /// Returns a list of all car types that are configured in the current setup.
  ///
  /// Throws:
  /// - [StateError] if manager is not initialized
  static List<String> getAvailableCarTypes() {
    _ensureInitialized();
    return IconManager.getAvailableCarTypes();
  }

  /// Reassign animation status (useful for dynamic updates)
  static void reassignAnimationStatus() {
    LifecycleManager.reassignAnimationStatus();
  }

  /// Clear all cache and resources
  static void clearCache() {
    LifecycleManager.cleanup();
  }

  /// Pauses all active animations.
  ///
  /// Temporarily stops all running animations without losing state.
  /// This is useful when the app goes to background or when you need
  /// to temporarily halt all animations for performance reasons.
  ///
  /// Example:
  /// ```dart
  /// // Pause animations when app goes to background
  /// @override
  /// void didChangeAppLifecycleState(AppLifecycleState state) {
  ///   if (state == AppLifecycleState.paused) {
  ///     AnimatedCarMarkerManager.pauseAllAnimations();
  ///   }
  /// }
  /// ```
  ///
  /// Note:
  /// Use [resumeAllAnimations] to restart paused animations.
  /// All animation state is preserved during pause.
  static void pauseAllAnimations() {
    LifecycleManager.pauseAll();
  }

  /// Resumes all paused animations.
  ///
  /// Restarts all previously paused animations with their preserved state.
  /// This should be called when the app returns to foreground or when
  /// you want to resume animations after a pause.
  ///
  /// Parameters:
  /// - [onUpdateMarker]: Callback function for marker updates during animation
  ///
  /// Example:
  /// ```dart
  /// // Resume animations when app returns to foreground
  /// @override
  /// void didChangeAppLifecycleState(AppLifecycleState state) {
  ///   if (state == AppLifecycleState.resumed) {
  ///     AnimatedCarMarkerManager.resumeAllAnimations(() {
  ///       updateAllMarkersOnMap();
  ///     });
  ///   }
  /// }
  /// ```
  ///
  /// Note:
  /// All drivers that were animating before pause will resume animation.
  /// The callback will be used for all resumed animations.
  static void resumeAllAnimations(VoidCallback onUpdateMarker) {
    LifecycleManager.resumeAll(onUpdateMarker);
  }

  /// Update car type for specific driver (if needed)
  static void updateDriverCarType(String driverId, String newCarType) {
    final availableTypes = IconManager.getAvailableCarTypes();
    if (!availableTypes.contains(newCarType)) {
      Logger.warning('Car type $newCarType not found in assets');
      return;
    }

    // Reset rotation for new car type
    AnimationManager.setRotationAngle(driverId, 0.0);
  }

  /// Retrieves detailed animation statistics for debugging.
  ///
  /// Returns a comprehensive map of animation data for the specified driver,
  /// including current angles, animation state, timing information, and
  /// performance metrics.
  ///
  /// Parameters:
  /// - [driverId]: Unique identifier for the driver
  ///
  /// Returns:
  /// A [Map] containing animation statistics, or an error map if driver not found.
  ///
  /// Example:
  /// ```dart
  /// final stats = AnimatedCarMarkerManager.getAnimationStats('driver123');
  /// print('Current angle: ${stats['currentAngle']}');
  /// print('Target angle: ${stats['targetAngle']}');
  /// print('Animation active: ${stats['isActive']}');
  /// print('Smoothing factor: ${stats['smoothingFactor']}');
  /// print('Animation ticks: ${stats['animationTicks']}');
  /// ```
  ///
  /// Available statistics:
  /// - `currentAngle`: Current rotation angle in degrees
  /// - `targetAngle`: Target rotation angle in degrees
  /// - `isActive`: Whether animation is currently running
  /// - `shouldAnimate`: Whether driver is configured to animate
  /// - `smoothingFactor`: Current smoothing factor (0.01-1.0)
  /// - `animationTicks`: Number of animation ticks elapsed
  /// - `targetChangeInterval`: Ticks between target changes
  /// - `currentTargetType`: Current rotation target type
  static Map<String, dynamic> getAnimationStats(String driverId) {
    final driver = AnimationManager.getDriver(driverId);
    if (driver == null) {
      return {'error': 'Driver not found'};
    }

    final stats = driver.toDebugMap();
    stats['isActive'] = AnimationManager.isAnimationActive(driverId);
    return stats;
  }

  /// Manually set rotation angle (useful for testing or specific scenarios)
  static void setRotationAngle(String driverId, double angle) {
    AnimationManager.setRotationAngle(driverId, angle);
  }

  /// Adjust animation smoothness (0.01 = very smooth, 1.0 = instant)
  static void setAnimationSmoothness(double smoothness) {
    // This method is kept for backward compatibility
    // Individual driver smoothness is now managed by AnimationManager
    Logger.debug('Global smoothness setting: $smoothness (managed per driver)');
  }

  /// Get current smoothing factor
  static double getAnimationSmoothness() {
    // Return default smoothness factor for backward compatibility
    return 0.25;
  }

  /// Set faster rotation speed for specific driver while maintaining smoothness
  static void setFasterRotation(
    String driverId, {
    double speedMultiplier = 2.0,
  }) {
    AnimationManager.setFasterRotation(
      driverId,
      speedMultiplier: speedMultiplier,
    );
  }

  /// Reset to normal rotation speed
  static void setNormalRotation(String driverId) {
    AnimationManager.setNormalRotation(driverId);
  }

  /// Starts animation with custom smoothness and speed settings.
  ///
  /// This enhanced version of [startAnimation] allows fine-tuning of
  /// animation parameters for specific drivers. You can customize
  /// smoothness and enable turbo mode for faster rotations.
  ///
  /// Parameters:
  /// - [driverId]: Unique identifier for the driver
  /// - [onUpdateMarker]: Callback function for marker updates
  /// - [customSmoothness]: Custom smoothing factor (0.01-1.0, optional)
  /// - [turboMode]: Enable faster rotation speed (default: false)
  ///
  /// Example:
  /// ```dart
  /// // Very smooth, slow animation
  /// AnimatedCarMarkerManager.startAnimationWithSmoothness(
  ///   'driver123',
  ///   () => updateMarker(),
  ///   customSmoothness: 0.05, // Very smooth
  /// );
  ///
  /// // Fast, dramatic animation
  /// AnimatedCarMarkerManager.startAnimationWithSmoothness(
  ///   'driver456',
  ///   () => updateMarker(),
  ///   customSmoothness: 0.4,
  ///   turboMode: true, // 3x speed multiplier
  /// );
  /// ```
  ///
  /// Smoothness values:
  /// - 0.01-0.1: Very smooth, slow transitions
  /// - 0.1-0.3: Balanced smoothness and responsiveness
  /// - 0.3-1.0: Fast, more immediate transitions
  ///
  /// Note:
  /// Turbo mode applies a 3x speed multiplier to rotation speed.
  /// Settings are applied per-driver and persist until changed.
  static void startAnimationWithSmoothness(
    String driverId,
    VoidCallback onUpdateMarker, {
    double? customSmoothness,
    bool turboMode = false,
  }) {
    final driver = AnimationManager.getDriver(driverId);
    if (driver != null) {
      // Set per-driver smoothness if provided
      if (customSmoothness != null) {
        driver.smoothingFactor = customSmoothness.clamp(0.01, 1.0);
      }

      // Enable turbo mode for extra fast rotation
      if (turboMode) {
        setFasterRotation(driverId, speedMultiplier: 3.0);
      }

      Logger.debug(
        "Starting animation for driver $driverId with smoothness: ${driver.smoothingFactor}, turbo: $turboMode",
      );
    }
    startAnimation(driverId, onUpdateMarker);
  }

  /// Start animation with turbo mode for very fast rotation
  static void startTurboAnimation(
    String driverId,
    VoidCallback onUpdateMarker,
  ) {
    startAnimationWithSmoothness(
      driverId,
      onUpdateMarker,
      customSmoothness: 0.4, // Higher smoothness for fast movement
      turboMode: true,
    );
  }

  /// Get all active animations for debugging
  static List<String> getActiveAnimations() {
    return AnimationManager.getActiveAnimations();
  }

  /// Get all drivers that should animate
  static List<String> getAnimatableDrivers() {
    return AnimationManager.getAnimatableDrivers();
  }

  /// Print summary of all animations
  static void printAnimationSummary() {
    final activeAnimations = getActiveAnimations();
    final animatableDrivers = getAnimatableDrivers();

    Logger.logSummary("Animation Summary", [
      "Total drivers that should animate: ${animatableDrivers.length}",
      "Active animations: ${activeAnimations.length}",
      "Animatable drivers: $animatableDrivers",
      "Active animations: $activeAnimations",
    ]);

    for (String driverId in animatableDrivers) {
      final stats = getAnimationStats(driverId);
      Logger.logAnimationStats(driverId, stats);
    }
  }

  /// Batch update multiple drivers for better performance
  static void batchUpdateDrivers(
    List<String> driverIds,
    Function(List<String>) onUpdateMarkers,
  ) {
    final updatedDrivers = <String>[];

    for (String driverId in driverIds) {
      final driver = AnimationManager.getDriver(driverId);
      if (driver != null &&
          driver.shouldAnimate &&
          AnimationManager.isAnimationActive(driverId)) {
        updatedDrivers.add(driverId);
      }
    }

    if (updatedDrivers.isNotEmpty) {
      onUpdateMarkers(updatedDrivers);
    }
  }

  /// Sets a specific rotation target for a driver.
  ///
  /// Forces the driver to use a specific rotation target type instead
  /// of the default random selection. This allows for controlled
  /// animation patterns and specific visual effects.
  ///
  /// Parameters:
  /// - [driverId]: Unique identifier for the driver
  /// - [targetType]: The rotation target type to use
  ///
  /// Example:
  /// ```dart
  /// // Make car always rotate to maximum angle
  /// AnimatedCarMarkerManager.setRotationTarget(
  ///   'driver123',
  ///   RotationTarget.maximum
  /// );
  ///
  /// // Make car return to center position
  /// AnimatedCarMarkerManager.setRotationTarget(
  ///   'driver456',
  ///   RotationTarget.center
  /// );
  ///
  /// // Use random targets (default behavior)
  /// AnimatedCarMarkerManager.setRotationTarget(
  ///   'driver789',
  ///   RotationTarget.random
  /// );
  /// ```
  ///
  /// Available target types:
  /// - [RotationTarget.maximum]: Rotate to maximum allowed angle
  /// - [RotationTarget.minimum]: Subtle rotation movements
  /// - [RotationTarget.random]: Random angle within limits
  /// - [RotationTarget.center]: Return to neutral position (0°)
  static void setRotationTarget(String driverId, RotationTarget targetType) {
    AnimationManager.setRotationTarget(driverId, targetType);
  }

  /// Get all drivers with their current status
  static Map<String, DriverAnimationModel> getAllDrivers() {
    return AnimationManager.getAllDrivers();
  }

  /// Set custom target change interval for a driver
  static void setTargetChangeInterval(String driverId, int intervalTicks) {
    AnimationManager.setTargetChangeInterval(driverId, intervalTicks);
  }
}
