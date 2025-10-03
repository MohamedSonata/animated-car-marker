import 'package:flutter/foundation.dart';

/// Production-safe logging utility for the Animated Car Marker package
///
/// This class provides a centralized logging system that replaces direct
/// print statements with production-safe alternatives. It uses Flutter's
/// debugPrint for debug messages and provides different log levels for
/// better categorization and filtering.
///
/// The logger automatically handles production vs debug environments:
/// - In debug mode: All messages are printed using debugPrint
/// - In release mode: Only error messages are printed to avoid log spam
/// - All messages include timestamps and log level indicators
///
/// Log levels:
/// - DEBUG: Detailed information for debugging (debug mode only)
/// - INFO: General information messages (debug mode only)
/// - WARNING: Warning messages that don't break functionality (debug mode only)
/// - ERROR: Error messages that indicate problems (always printed)
///
/// Example usage:
/// ```dart
/// // Debug information (only in debug mode)
/// Logger.debug('Animation started for driver: driver123');
///
/// // General information
/// Logger.info('Preloaded 5 car icons successfully');
///
/// // Warning about non-critical issues
/// Logger.warning('Car type "unknown" not found, using default');
///
/// // Error for critical issues (always printed)
/// Logger.error('Failed to load car icon', exception);
/// ```
class Logger {
  // Private constructor to prevent instantiation
  Logger._();

  /// Log level enumeration for message categorization
  static const String _debugLevel = 'DEBUG';
  static const String _infoLevel = 'INFO';
  static const String _warningLevel = 'WARNING';
  static const String _errorLevel = 'ERROR';

  /// Maximum message length to prevent extremely long log entries
  static const int _maxMessageLength = 500;

  /// Log a debug message
  ///
  /// Debug messages provide detailed information useful during development
  /// and troubleshooting. These messages are only printed in debug mode
  /// to avoid cluttering production logs.
  ///
  /// Use for:
  /// - Animation state changes
  /// - Detailed calculation results
  /// - Internal method entry/exit points
  /// - Variable values during debugging
  ///
  /// Parameters:
  /// - [message]: The debug message to log
  /// - [details]: Optional additional details or context
  ///
  /// Example:
  /// ```dart
  /// Logger.debug('Driver animation tick', 'driverId: $driverId, angle: $angle');
  /// Logger.debug('Target angle calculated: ${targetAngle.toStringAsFixed(2)}°');
  /// ```
  static void debug(String message, [String? details]) {
    if (kDebugMode) {
      _logMessage(_debugLevel, message, details);
    }
  }

  /// Log an informational message
  ///
  /// Info messages provide general information about the system's operation.
  /// These are useful for tracking major operations and system state changes.
  /// Only printed in debug mode.
  ///
  /// Use for:
  /// - Successful operations completion
  /// - System initialization messages
  /// - Configuration changes
  /// - Performance metrics
  ///
  /// Parameters:
  /// - [message]: The informational message to log
  /// - [details]: Optional additional details or context
  ///
  /// Example:
  /// ```dart
  /// Logger.info('Car icons preloaded successfully', 'count: ${iconCount}');
  /// Logger.info('Animation manager initialized for ${driverCount} drivers');
  /// ```
  static void info(String message, [String? details]) {
    if (kDebugMode) {
      _logMessage(_infoLevel, message, details);
    }
  }

  /// Log a warning message
  ///
  /// Warning messages indicate potential issues or unexpected conditions
  /// that don't prevent the system from functioning but should be noted.
  /// Only printed in debug mode.
  ///
  /// Use for:
  /// - Fallback operations being used
  /// - Invalid but recoverable input
  /// - Performance concerns
  /// - Deprecated feature usage
  ///
  /// Parameters:
  /// - [message]: The warning message to log
  /// - [details]: Optional additional details or context
  ///
  /// Example:
  /// ```dart
  /// Logger.warning('Car type not found, using default', 'requested: $carType');
  /// Logger.warning('Animation speed clamped to maximum', 'requested: $speed');
  /// ```
  static void warning(String message, [String? details]) {
    if (kDebugMode) {
      _logMessage(_warningLevel, message, details);
    }
  }

  /// Log an error message
  ///
  /// Error messages indicate serious problems that may affect functionality.
  /// These messages are always printed, even in release mode, as they
  /// represent critical issues that need attention.
  ///
  /// Use for:
  /// - Exception handling
  /// - Critical operation failures
  /// - Resource loading errors
  /// - Invalid state conditions
  ///
  /// Parameters:
  /// - [message]: The error message to log
  /// - [error]: Optional error object or exception
  /// - [stackTrace]: Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// Logger.error('Failed to load car icon', exception);
  /// Logger.error('Invalid driver ID provided', 'driverId: $driverId');
  ///
  /// try {
  ///   // risky operation
  /// } catch (e, stackTrace) {
  ///   Logger.error('Operation failed', e, stackTrace);
  /// }
  /// ```
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    // Always log errors, even in release mode
    final errorDetails = error?.toString();
    _logMessage(_errorLevel, message, errorDetails);

    // Print stack trace if provided and in debug mode
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Internal method to format and print log messages
  ///
  /// Handles the actual message formatting and printing using debugPrint
  /// for production-safe logging. Includes timestamp, log level, and
  /// message truncation for readability.
  ///
  /// Parameters:
  /// - [level]: The log level (DEBUG, INFO, WARNING, ERROR)
  /// - [message]: The main message to log
  /// - [details]: Optional additional details
  static void _logMessage(String level, String message, [String? details]) {
    final timestamp = DateTime.now().toIso8601String().substring(
      11,
      23,
    ); // HH:mm:ss.SSS
    final levelPadded = level.padRight(7); // Align log levels

    // Truncate message if too long
    String finalMessage = message;
    if (finalMessage.length > _maxMessageLength) {
      finalMessage = '${finalMessage.substring(0, _maxMessageLength - 3)}...';
    }

    // Build the complete log entry
    final logEntry = StringBuffer('[$timestamp] $levelPadded $finalMessage');

    // Add details if provided
    if (details != null && details.isNotEmpty) {
      String finalDetails = details;
      if (finalDetails.length > _maxMessageLength) {
        finalDetails = '${finalDetails.substring(0, _maxMessageLength - 3)}...';
      }
      logEntry.write(' | $finalDetails');
    }

    // Use debugPrint for production-safe logging
    debugPrint(logEntry.toString());
  }

  /// Log animation statistics for debugging
  ///
  /// Specialized logging method for animation-related statistics and metrics.
  /// Formats animation data in a consistent, readable format for debugging
  /// and performance monitoring.
  ///
  /// Parameters:
  /// - [driverId]: The driver identifier
  /// - [stats]: Map containing animation statistics
  ///
  /// Example:
  /// ```dart
  /// final stats = {
  ///   'currentAngle': 45.5,
  ///   'targetAngle': 90.0,
  ///   'animationSpeed': 0.25,
  ///   'isActive': true,
  /// };
  /// Logger.logAnimationStats('driver123', stats);
  /// ```
  static void logAnimationStats(String driverId, Map<String, dynamic> stats) {
    if (kDebugMode) {
      final formattedStats = stats.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(', ');
      debug('Animation stats for $driverId', formattedStats);
    }
  }

  /// Log performance metrics
  ///
  /// Specialized logging for performance-related information such as
  /// timing, memory usage, and operation counts. Useful for monitoring
  /// system performance and identifying bottlenecks.
  ///
  /// Parameters:
  /// - [operation]: The operation being measured
  /// - [duration]: Duration of the operation
  /// - [additionalMetrics]: Optional additional performance data
  ///
  /// Example:
  /// ```dart
  /// final stopwatch = Stopwatch()..start();
  /// // ... perform operation ...
  /// stopwatch.stop();
  ///
  /// Logger.logPerformance(
  ///   'Icon preloading',
  ///   stopwatch.elapsed,
  ///   {'iconCount': 5, 'cacheSize': '2.1MB'},
  /// );
  /// ```
  static void logPerformance(
    String operation,
    Duration duration, [
    Map<String, dynamic>? additionalMetrics,
  ]) {
    if (kDebugMode) {
      final durationMs = duration.inMilliseconds;
      String message = 'Performance: $operation completed in ${durationMs}ms';

      String? details;
      if (additionalMetrics != null && additionalMetrics.isNotEmpty) {
        details = additionalMetrics.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join(', ');
      }

      info(message, details);
    }
  }

  /// Log system lifecycle events
  ///
  /// Specialized logging for application lifecycle events such as
  /// initialization, pause, resume, and cleanup operations.
  ///
  /// Parameters:
  /// - [event]: The lifecycle event name
  /// - [context]: Optional context information
  ///
  /// Example:
  /// ```dart
  /// Logger.logLifecycle('Animation system initialized', 'driverCount: 10');
  /// Logger.logLifecycle('All animations paused', 'reason: app backgrounded');
  /// Logger.logLifecycle('Resources cleaned up', 'cacheCleared: true');
  /// ```
  static void logLifecycle(String event, [String? context]) {
    info('Lifecycle: $event', context);
  }

  /// Check if debug logging is enabled
  ///
  /// Utility method to check if debug-level logging is currently enabled.
  /// Useful for conditional logging or expensive debug operations.
  ///
  /// Returns true if running in debug mode, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (Logger.isDebugEnabled()) {
  ///   final expensiveDebugInfo = calculateComplexStats();
  ///   Logger.debug('Complex stats', expensiveDebugInfo);
  /// }
  /// ```
  static bool isDebugEnabled() {
    return kDebugMode;
  }

  /// Create a formatted summary of multiple log entries
  ///
  /// Utility method for creating formatted summaries of related operations
  /// or statistics. Useful for periodic reporting or debugging sessions.
  ///
  /// Parameters:
  /// - [title]: The summary title
  /// - [entries]: List of summary entries
  ///
  /// Example:
  /// ```dart
  /// Logger.logSummary('Animation System Status', [
  ///   'Active drivers: 5',
  ///   'Total animations: 3',
  ///   'Cache size: 2.1MB',
  ///   'Average FPS: 9.8',
  /// ]);
  /// ```
  static void logSummary(String title, List<String> entries) {
    if (kDebugMode) {
      debug('=== $title ===');
      for (final entry in entries) {
        debug('  $entry');
      }
      debug('=' * (title.length + 8));
    }
  }
}
