/// Animated Car Marker Package
///
/// A Flutter package for creating smooth animated car markers on Google Maps.
/// This package provides easy-to-use APIs for managing animated car markers
/// with rotation, lifecycle management, and performance optimization.
///
/// ## Features
/// - Smooth rotation animations for car markers
/// - Multiple car types with icon caching
/// - Lifecycle management (pause/resume)
/// - Performance optimized for multiple markers
/// - Clean API with comprehensive documentation
///
/// ## Basic Usage
/// ```dart
/// import 'package:animated_car_marker/animated_car_marker.dart';
///
/// // Initialize with default configuration
/// await AnimatedCarMarkerManager.initialize();
///
/// // Initialize and start animation
/// AnimatedCarMarkerManager.initializeDriver('driver123');
/// AnimatedCarMarkerManager.startAnimation('driver123', () {
///   // Update your map marker here
/// });
///
/// // Create rotated marker
/// final marker = MarkerRotation.createRotatedMarker(
///   markerId: 'driver123',
///   position: LatLng(37.7749, -122.4194),
///   icon: AnimatedCarMarkerManager.getCarIcon('taxi'),
///   rotation: AnimatedCarMarkerManager.getCurrentRotationAngle('driver123'),
/// );
/// ```
///
/// ## Custom Assets Usage
/// ```dart
/// import 'package:animated_car_marker/animated_car_marker.dart';
///
/// // Create custom configuration
/// final config = AnimatedCarConfig(
///   carAssets: {
///     'taxi': [CarAssetModel(assetPath: 'assets/my_taxi.png')],
///     'luxury': [CarAssetModel(assetPath: 'assets/my_luxury.png')],
///   },
///   iconSize: 50.0,
///   animationProbability: 30,
/// );
///
/// // Initialize with custom configuration
/// await AnimatedCarMarkerManager.initialize(config: config);
/// ```
library;

// Export public API classes and managers
export 'src/marker_loader.dart' show AnimatedCarMarkerManager;

// Export public models and enums
export 'src/models/rotation_target.dart';
export 'src/models/car_asset_model.dart';
export 'src/models/animated_car_config.dart';

// Export public extensions
export 'src/extensions/marker_rotation.dart';
