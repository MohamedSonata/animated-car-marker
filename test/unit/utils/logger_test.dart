import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/src/utils/logger.dart';

/// Unit tests for Logger utility class
/// 
/// Tests the logging functionality including different log levels,
/// message formatting, and production-safe behavior.
void main() {
  group('Logger Unit Tests', () {
    group('Debug Logging', () {
      test('should log debug messages in debug mode', () {
        // Note: In test environment, kDebugMode is typically true
        expect(() => Logger.debug('Test debug message'), returnsNormally);
      });

      test('should log debug messages with details', () {
        expect(
          () => Logger.debug('Test debug message', 'Additional details'),
          returnsNormally,
        );
      });

      test('should handle null details in debug', () {
        expect(() => Logger.debug('Test debug message', null), returnsNormally);
      });

      test('should handle empty details in debug', () {
        expect(() => Logger.debug('Test debug message', ''), returnsNormally);
      });
    });

    group('Info Logging', () {
      test('should log info messages in debug mode', () {
        expect(() => Logger.info('Test info message'), returnsNormally);
      });

      test('should log info messages with details', () {
        expect(
          () => Logger.info('Test info message', 'Additional details'),
          returnsNormally,
        );
      });

      test('should handle null details in info', () {
        expect(() => Logger.info('Test info message', null), returnsNormally);
      });

      test('should handle empty details in info', () {
        expect(() => Logger.info('Test info message', ''), returnsNormally);
      });
    });

    group('Warning Logging', () {
      test('should log warning messages in debug mode', () {
        expect(() => Logger.warning('Test warning message'), returnsNormally);
      });

      test('should log warning messages with details', () {
        expect(
          () => Logger.warning('Test warning message', 'Additional details'),
          returnsNormally,
        );
      });

      test('should handle null details in warning', () {
        expect(() => Logger.warning('Test warning message', null), returnsNormally);
      });

      test('should handle empty details in warning', () {
        expect(() => Logger.warning('Test warning message', ''), returnsNormally);
      });
    });

    group('Error Logging', () {
      test('should log error messages', () {
        expect(() => Logger.error('Test error message'), returnsNormally);
      });

      test('should log error messages with error object', () {
        final exception = Exception('Test exception');
        expect(() => Logger.error('Test error message', exception), returnsNormally);
      });

      test('should log error messages with stack trace', () {
        final exception = Exception('Test exception');
        final stackTrace = StackTrace.current;
        expect(
          () => Logger.error('Test error message', exception, stackTrace),
          returnsNormally,
        );
      });

      test('should handle null error object', () {
        expect(() => Logger.error('Test error message', null), returnsNormally);
      });

      test('should handle null stack trace', () {
        final exception = Exception('Test exception');
        expect(() => Logger.error('Test error message', exception, null), returnsNormally);
      });
    });

    group('Specialized Logging Methods', () {
      test('should log animation statistics', () {
        final stats = {
          'driverId': 'test_driver',
          'currentAngle': 45.5,
          'targetAngle': 90.0,
          'animationSpeed': 0.25,
          'isActive': true,
        };
        
        expect(() => Logger.logAnimationStats('test_driver', stats), returnsNormally);
      });

      test('should handle empty animation statistics', () {
        final stats = <String, dynamic>{};
        expect(() => Logger.logAnimationStats('test_driver', stats), returnsNormally);
      });

      test('should log performance metrics', () {
        final duration = const Duration(milliseconds: 150);
        expect(() => Logger.logPerformance('Test operation', duration), returnsNormally);
      });

      test('should log performance metrics with additional data', () {
        final duration = const Duration(milliseconds: 150);
        final additionalMetrics = {
          'itemCount': 10,
          'memoryUsage': '2.1MB',
          'cacheHits': 8,
        };
        
        expect(
          () => Logger.logPerformance('Test operation', duration, additionalMetrics),
          returnsNormally,
        );
      });

      test('should handle null additional metrics in performance logging', () {
        final duration = const Duration(milliseconds: 150);
        expect(() => Logger.logPerformance('Test operation', duration, null), returnsNormally);
      });

      test('should log lifecycle events', () {
        expect(() => Logger.logLifecycle('System initialized'), returnsNormally);
      });

      test('should log lifecycle events with context', () {
        expect(
          () => Logger.logLifecycle('System initialized', 'driverCount: 5'),
          returnsNormally,
        );
      });

      test('should handle null context in lifecycle logging', () {
        expect(() => Logger.logLifecycle('System initialized', null), returnsNormally);
      });
    });

    group('Summary Logging', () {
      test('should log summary with entries', () {
        final entries = [
          'Active drivers: 5',
          'Total animations: 3',
          'Cache size: 2.1MB',
          'Average FPS: 9.8',
        ];
        
        expect(() => Logger.logSummary('System Status', entries), returnsNormally);
      });

      test('should handle empty summary entries', () {
        final entries = <String>[];
        expect(() => Logger.logSummary('Empty Status', entries), returnsNormally);
      });

      test('should handle single summary entry', () {
        final entries = ['Single entry'];
        expect(() => Logger.logSummary('Single Status', entries), returnsNormally);
      });
    });

    group('Utility Methods', () {
      test('should report debug enabled status', () {
        final isEnabled = Logger.isDebugEnabled();
        expect(isEnabled, isA<bool>());
        // In test environment, this is typically true
        expect(isEnabled, equals(kDebugMode));
      });
    });

    group('Message Formatting and Limits', () {
      test('should handle very long messages', () {
        final longMessage = 'A' * 1000; // 1000 character message
        expect(() => Logger.debug(longMessage), returnsNormally);
        expect(() => Logger.info(longMessage), returnsNormally);
        expect(() => Logger.warning(longMessage), returnsNormally);
        expect(() => Logger.error(longMessage), returnsNormally);
      });

      test('should handle very long details', () {
        final longDetails = 'B' * 1000; // 1000 character details
        expect(() => Logger.debug('Short message', longDetails), returnsNormally);
        expect(() => Logger.info('Short message', longDetails), returnsNormally);
        expect(() => Logger.warning('Short message', longDetails), returnsNormally);
      });

      test('should handle special characters in messages', () {
        const specialMessage = 'Message with special chars: \n\t\r"\'\\';
        expect(() => Logger.debug(specialMessage), returnsNormally);
        expect(() => Logger.info(specialMessage), returnsNormally);
        expect(() => Logger.warning(specialMessage), returnsNormally);
        expect(() => Logger.error(specialMessage), returnsNormally);
      });

      test('should handle unicode characters in messages', () {
        const unicodeMessage = 'Unicode: 🚗 ➡️ 🎯 ✅';
        expect(() => Logger.debug(unicodeMessage), returnsNormally);
        expect(() => Logger.info(unicodeMessage), returnsNormally);
        expect(() => Logger.warning(unicodeMessage), returnsNormally);
        expect(() => Logger.error(unicodeMessage), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle logging with various error types', () {
        final exception = Exception('Test exception');
        final argumentError = ArgumentError('Invalid argument');
        final stateError = StateError('Invalid state');
        
        expect(() => Logger.error('Exception test', exception), returnsNormally);
        expect(() => Logger.error('ArgumentError test', argumentError), returnsNormally);
        expect(() => Logger.error('StateError test', stateError), returnsNormally);
      });

      test('should handle logging with string error', () {
        const stringError = 'String error message';
        expect(() => Logger.error('String error test', stringError), returnsNormally);
      });

      test('should handle logging with number error', () {
        const numberError = 404;
        expect(() => Logger.error('Number error test', numberError), returnsNormally);
      });
    });

    group('Concurrent Logging', () {
      test('should handle concurrent logging calls', () async {
        final futures = <Future<void>>[];
        
        // Create multiple concurrent logging operations
        for (int i = 0; i < 20; i++) {
          futures.add(Future(() {
            Logger.debug('Concurrent debug $i');
            Logger.info('Concurrent info $i');
            Logger.warning('Concurrent warning $i');
            Logger.error('Concurrent error $i');
          }));
        }
        
        // Should complete without errors
        await Future.wait(futures);
      });

      test('should handle rapid successive logging calls', () {
        const callCount = 100;
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < callCount; i++) {
          Logger.debug('Rapid call $i');
        }
        
        stopwatch.stop();
        
        // Should complete quickly (less than 100ms for 100 calls)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Performance Tests', () {
      test('should perform logging efficiently', () {
        const iterations = 1000;
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < iterations; i++) {
          Logger.debug('Performance test message $i', 'details $i');
        }
        
        stopwatch.stop();
        
        // Should complete quickly (less than 500ms for 1000 iterations)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      test('should handle complex data structures efficiently', () {
        final complexData = {
          'level1': {
            'level2': {
              'level3': List.generate(100, (i) => 'item_$i'),
            },
          },
          'arrays': List.generate(50, (i) => {'id': i, 'name': 'name_$i'}),
          'numbers': List.generate(100, (i) => i * 3.14159),
        };
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10; i++) {
          Logger.logAnimationStats('complex_test_$i', complexData);
        }
        
        stopwatch.stop();
        
        // Should handle complex data without excessive delay
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Integration Tests', () {
      test('should work with all log levels in sequence', () {
        expect(() {
          Logger.debug('Debug message');
          Logger.info('Info message');
          Logger.warning('Warning message');
          Logger.error('Error message');
        }, returnsNormally);
      });

      test('should work with mixed specialized logging methods', () {
        final stats = {'angle': 45.0, 'speed': 0.25};
        final duration = const Duration(milliseconds: 100);
        final metrics = {'count': 5};
        final entries = ['Entry 1', 'Entry 2'];
        
        expect(() {
          Logger.logAnimationStats('test_driver', stats);
          Logger.logPerformance('test_operation', duration, metrics);
          Logger.logLifecycle('test_event', 'context');
          Logger.logSummary('test_summary', entries);
        }, returnsNormally);
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        expect(() => Logger.debug(''), returnsNormally);
        expect(() => Logger.info(''), returnsNormally);
        expect(() => Logger.warning(''), returnsNormally);
        expect(() => Logger.error(''), returnsNormally);
      });

      test('should handle whitespace-only strings', () {
        expect(() => Logger.debug('   '), returnsNormally);
        expect(() => Logger.info('\t\n'), returnsNormally);
        expect(() => Logger.warning('  \r\n  '), returnsNormally);
        expect(() => Logger.error('\t'), returnsNormally);
      });

      test('should handle zero duration in performance logging', () {
        final zeroDuration = Duration.zero;
        expect(() => Logger.logPerformance('Zero duration', zeroDuration), returnsNormally);
      });

      test('should handle negative duration in performance logging', () {
        final negativeDuration = const Duration(milliseconds: -100);
        expect(() => Logger.logPerformance('Negative duration', negativeDuration), returnsNormally);
      });
    });
  });
}