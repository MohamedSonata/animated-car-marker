import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'animated_car_marker_test.dart' as main_test;
import 'performance_test.dart' as performance_test;
import 'resource_management_test.dart' as resource_test;
import 'validation_test.dart' as validation_test;

// Unit tests
import 'unit/managers/animation_manager_test.dart' as animation_manager_test;
import 'unit/managers/lifecycle_manager_test.dart' as lifecycle_manager_test;
import 'unit/managers/icon_manager_test.dart' as icon_manager_test;
import 'unit/utils/animation_calculator_test.dart' as calculator_test;
import 'unit/utils/logger_test.dart' as logger_test;
import 'unit/models/driver_animation_model_test.dart' as model_test;

// Integration tests
import 'integration/animation_workflow_test.dart' as workflow_test;

// Performance tests
import 'performance/performance_regression_test.dart' as regression_test;

/// Comprehensive test suite runner
/// 
/// This file imports and runs all test suites for the animated car marker package.
/// It provides a single entry point to execute the complete test suite including:
/// - Unit tests for all manager classes and utilities
/// - Integration tests for complete animation workflows
/// - Performance regression tests
/// - Resource management validation tests
void main() {
  group('Animated Car Marker - Complete Test Suite', () {
    group('Main Package Tests', () {
      main_test.main();
    });

    group('Unit Tests', () {
      group('Manager Classes', () {
        animation_manager_test.main();
        lifecycle_manager_test.main();
        icon_manager_test.main();
      });

      group('Utility Classes', () {
        calculator_test.main();
        logger_test.main();
      });

      group('Model Classes', () {
        model_test.main();
      });
    });

    group('Integration Tests', () {
      workflow_test.main();
    });

    group('Validation Tests', () {
      validation_test.main();
    });

    group('Performance Tests', () {
      performance_test.main();
      regression_test.main();
    });

    group('Resource Management Tests', () {
      resource_test.main();
    });
  });
}