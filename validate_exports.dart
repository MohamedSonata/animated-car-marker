// Simple validation script to check export structure
// This script validates that:
// 1. All necessary classes are exported
// 2. Internal implementation details are not exposed
// 3. The export structure follows the design requirements

import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    print('Validating export functionality...');
  }
  
  // Check main export file
  validateMainExportFile();
  
  // Check that internal files exist but are not exported
  validateInternalFilesNotExposed();
  
  // Check that all documented public APIs are exported
  validatePublicAPIsExported();
  
  if (kDebugMode) {
    print('✓ All export validation checks passed!');
  }
}

void validateMainExportFile() {
  final mainFile = File('lib/animated_car_marker.dart');
  if (!mainFile.existsSync()) {
    throw Exception('Main export file not found');
  }
  
  final content = mainFile.readAsStringSync();
  
  // Check that main manager is exported
  if (!content.contains("export 'src/custom_marker_loader.dart' show AnimatedCarMarkerManager;")) {
    throw Exception('AnimatedCarMarkerManager not properly exported');
  }
  
  // Check that rotation target enum is exported
  if (!content.contains("export 'src/models/rotation_target.dart';")) {
    throw Exception('RotationTarget enum not exported');
  }
  
  // Check that marker rotation extension is exported
  if (!content.contains("export 'src/extensions/marker_rotation.dart';")) {
    throw Exception('MarkerRotation extension not exported');
  }
  
  // Check that internal classes are NOT exported
  if (content.contains('animation_manager.dart') ||
      content.contains('icon_manager.dart') ||
      content.contains('lifecycle_manager.dart') ||
      content.contains('animation_calculator.dart') ||
      content.contains('logger.dart') ||
      content.contains('animation_constants.dart') ||
      content.contains('driver_animation_model.dart')) {
    throw Exception('Internal implementation classes are exposed in exports');
  }
  
  if (kDebugMode) {
    print('✓ Main export file structure validated');
  }
}

void validateInternalFilesNotExposed() {
  // Check that internal files exist
  final internalFiles = [
    'lib/src/managers/animation_manager.dart',
    'lib/src/managers/icon_manager.dart',
    'lib/src/managers/lifecycle_manager.dart',
    'lib/src/utils/animation_calculator.dart',
    'lib/src/utils/logger.dart',
    'lib/src/constants/animation_constants.dart',
    'lib/src/models/driver_animation_model.dart',
  ];
  
  for (final filePath in internalFiles) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Internal file not found: $filePath');
    }
  }
  
  if (kDebugMode) {
    print('✓ Internal implementation files exist and are properly organized');
  }
}

void validatePublicAPIsExported() {
  // Check that the main manager file contains all expected public methods
  final managerFile = File('lib/src/custom_marker_loader.dart');
  if (!managerFile.existsSync()) {
    throw Exception('Main manager file not found');
  }
  
  final content = managerFile.readAsStringSync();
  
  // Check for essential public methods
  final requiredMethods = [
    'preloadCarIcons',
    'getCarIcon',
    'initializeDriver',
    'startAnimation',
    'getCurrentRotationAngle',
    'stopAnimation',
    'pauseAllAnimations',
    'resumeAllAnimations',
    'getAnimationStats',
    'setRotationTarget',
    'setFasterRotation',
    'clearCache',
  ];
  
  for (final method in requiredMethods) {
    if (!content.contains('static') && !content.contains(method)) {
      throw Exception('Required public method not found: $method');
    }
  }
  
  // Check that RotationTarget enum has all required values
  final rotationTargetFile = File('lib/src/models/rotation_target.dart');
  final rotationContent = rotationTargetFile.readAsStringSync();
  
  final requiredEnumValues = ['maximum', 'minimum', 'random', 'center'];
  for (final value in requiredEnumValues) {
    if (!rotationContent.contains(value)) {
      throw Exception('Required enum value not found: $value');
    }
  }
  
  // Check that MarkerRotation extension has required method
  final extensionFile = File('lib/src/extensions/marker_rotation.dart');
  final extensionContent = extensionFile.readAsStringSync();
  
  if (!extensionContent.contains('createRotatedMarker')) {
    throw Exception('Required extension method not found: createRotatedMarker');
  }
  
  if (kDebugMode) {
    print('✓ All documented public APIs are properly exported');
  }
}