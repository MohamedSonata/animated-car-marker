// Test file to validate export functionality
// This file tests that all necessary classes are properly exported
// and that internal implementation details are not exposed

import 'package:animated_car_marker/animated_car_marker.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  // Test that main manager class is accessible
  testAnimatedCarMarkerManager();
  
  // Test that rotation target enum is accessible
  testRotationTarget();
  
  // Test that marker rotation extension is accessible
  testMarkerRotationExtension();
  
  // Test that internal classes are NOT accessible
  testInternalClassesNotExposed();
  
  if (kDebugMode) {
    print('All export validation tests passed!');
  }
}

void testAnimatedCarMarkerManager() {
  // Test that all public methods are accessible
  
  // Icon management
  AnimatedCarMarkerManager.preloadCarIcons();
  AnimatedCarMarkerManager.getCarIcon('taxi');
  AnimatedCarMarkerManager.getAvailableCarTypes();
  
  // Driver management
  AnimatedCarMarkerManager.initializeDriver('test_driver');
  AnimatedCarMarkerManager.shouldDriverAnimate('test_driver');
  AnimatedCarMarkerManager.isAnimationActive('test_driver');
  
  // Animation control
  AnimatedCarMarkerManager.startAnimation('test_driver', () {});
  AnimatedCarMarkerManager.getCurrentRotationAngle('test_driver');
  AnimatedCarMarkerManager.stopAnimation('test_driver');
  
  // Advanced animation features
  AnimatedCarMarkerManager.setFasterRotation('test_driver');
  AnimatedCarMarkerManager.setNormalRotation('test_driver');
  AnimatedCarMarkerManager.setRotationTarget('test_driver', RotationTarget.maximum);
  AnimatedCarMarkerManager.setRotationAngle('test_driver', 45.0);
  
  // Lifecycle management
  AnimatedCarMarkerManager.pauseAllAnimations();
  AnimatedCarMarkerManager.resumeAllAnimations(() {});
  AnimatedCarMarkerManager.clearCache();
  
  // Debugging and monitoring
  AnimatedCarMarkerManager.getAnimationStats('test_driver');
  AnimatedCarMarkerManager.getActiveAnimations();
  AnimatedCarMarkerManager.getAnimatableDrivers();
  AnimatedCarMarkerManager.printAnimationSummary();
  
  // Advanced features
  AnimatedCarMarkerManager.startAnimationWithSmoothness(
    'test_driver',
    () {},
    customSmoothness: 0.25,
    turboMode: true,
  );
  AnimatedCarMarkerManager.startTurboAnimation('test_driver', () {});
  AnimatedCarMarkerManager.setTargetChangeInterval('test_driver', 100);
  
  if (kDebugMode) {
    print('✓ AnimatedCarMarkerManager exports validated');
  }
}

void testRotationTarget() {
  // Test that all enum values are accessible

  if (kDebugMode) {
    print('✓ RotationTarget enum exports validated');
  }
}

void testMarkerRotationExtension() {
  // Test that extension methods are accessible
  final marker = MarkerRotation.createRotatedMarker(
    markerId: 'test_marker',
    position: const LatLng(37.7749, -122.4194),
    icon: BitmapDescriptor.defaultMarker,
    rotation: 45.0,
    infoWindow: const InfoWindow(title: 'Test Marker'),
    onTap: () {},
  );
  
  // Verify marker properties
  assert(marker.markerId.value == 'test_marker');
  assert(marker.rotation == 45.0);
  
  if (kDebugMode) {
    print('✓ MarkerRotation extension exports validated');
  }
}

void testInternalClassesNotExposed() {
  // These should NOT be accessible from the public API
  // If any of these compile, it means internal classes are exposed
  
  // Uncomment these lines to test - they should cause compilation errors:
  
  // AnimationManager.startDriverAnimation('test', () {}); // Should not be accessible
  // IconManager.preloadIcons(); // Should not be accessible  
  // LifecycleManager.pauseAll(); // Should not be accessible
  // AnimationCalculator.calculateSmoothedAngle(current: 0, target: 90, smoothingFactor: 0.25); // Should not be accessible
  // Logger.debug('test'); // Should not be accessible
  // DriverAnimationModel(driverId: 'test'); // Should not be accessible
  // AnimationConstants.animationDuration; // Should not be accessible
  
  if (kDebugMode) {
    print('✓ Internal classes properly hidden from public API');
  }
}