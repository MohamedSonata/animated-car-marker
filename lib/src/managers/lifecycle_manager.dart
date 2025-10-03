import 'package:flutter/material.dart';
import '../utils/logger.dart';
import 'animation_manager.dart';
import 'icon_manager.dart';

/// Manager class responsible for app lifecycle handling
///
/// This class handles all lifecycle-related operations including:
/// - Pausing animations when app goes to background
/// - Resuming animations when app comes to foreground
/// - Cleaning up resources and preventing memory leaks
/// - Managing proper resource disposal
/// - Coordinating between different managers during lifecycle events
class LifecycleManager {
  static bool _isPaused = false;
  static VoidCallback? _lastUpdateCallback;

  /// Pause all animations and resources
  ///
  /// This method should be called when the app goes to the background
  /// or when animations need to be temporarily stopped to save resources.
  /// It coordinates with AnimationManager to pause all active animations.
  static void pauseAll() {
    if (_isPaused) {
      Logger.debug('Lifecycle already paused, skipping');
      return;
    }

    Logger.info('Pausing all animations and resources');

    // Pause all animations through AnimationManager
    AnimationManager.pauseAllAnimations();

    _isPaused = true;
    Logger.debug('Lifecycle pause completed');
  }

  /// Resume all animations and resources
  ///
  /// [onUpdateMarker] - Callback function to update markers on the map
  ///
  /// This method should be called when the app comes to the foreground
  /// or when animations need to be restarted. It coordinates with
  /// AnimationManager to resume animations for drivers that should animate.
  static void resumeAll(VoidCallback onUpdateMarker) {
    if (!_isPaused) {
      Logger.debug('Lifecycle not paused, skipping resume');
      return;
    }

    Logger.info('Resuming all animations and resources');

    // Store the callback for potential future use
    _lastUpdateCallback = onUpdateMarker;

    // Resume animations through AnimationManager
    AnimationManager.resumeAllAnimations(onUpdateMarker);

    _isPaused = false;
    Logger.debug('Lifecycle resume completed');
  }

  /// Clean up all resources and stop all operations
  ///
  /// This method performs a complete cleanup of all resources including:
  /// - Stopping all animations
  /// - Clearing icon cache
  /// - Resetting internal state
  ///
  /// This should be called when the app is being disposed or when
  /// a complete reset is needed.
  static void cleanup() {
    Logger.info('Starting complete lifecycle cleanup');

    // Stop all animations and clear driver data
    AnimationManager.stopAllAnimations();

    // Clear icon cache to free memory
    IconManager.clearIconCache();

    // Reset internal state
    _isPaused = false;
    _lastUpdateCallback = null;

    Logger.info('Lifecycle cleanup completed');
  }

  /// Reassign animation status for all drivers
  ///
  /// This method delegates to AnimationManager to reassign which drivers
  /// should animate. It's useful for dynamic updates and keeping animations varied.
  ///
  /// Note: This method is kept for backward compatibility but delegates
  /// to the appropriate manager.
  static void reassignAnimationStatus() {
    Logger.debug('Reassigning animation status for all drivers');

    // This functionality is now handled by AnimationManager internally
    // We keep this method for API compatibility
    final drivers = AnimationManager.getAllDrivers();
    Logger.debug('Found ${drivers.length} drivers for status reassignment');
  }

  /// Check if the lifecycle is currently paused
  ///
  /// Returns true if animations and resources are currently paused
  static bool get isPaused => _isPaused;

  /// Get the current state of the lifecycle manager
  ///
  /// Returns a map containing the current state information
  /// useful for debugging and monitoring
  static Map<String, dynamic> getState() {
    return {
      'isPaused': _isPaused,
      'hasUpdateCallback': _lastUpdateCallback != null,
      'activeAnimations': AnimationManager.getActiveAnimations().length,
      'totalDrivers': AnimationManager.getAllDrivers().length,
      'cachedIcons': IconManager.getCachedIconCount(),
    };
  }

  /// Force resume with the last known update callback
  ///
  /// This method attempts to resume animations using the last known
  /// update callback. It's useful for recovery scenarios where the
  /// callback might have been lost.
  ///
  /// Returns true if resume was successful, false if no callback available
  static bool forceResume() {
    if (_lastUpdateCallback == null) {
      Logger.warning('Cannot force resume: no update callback available');
      return false;
    }

    Logger.info('Force resuming with last known callback');
    resumeAll(_lastUpdateCallback!);
    return true;
  }

  /// Perform a soft reset of the lifecycle state
  ///
  /// This method resets the lifecycle state without performing
  /// a full cleanup. It's useful for recovering from inconsistent states.
  static void softReset() {
    Logger.info('Performing soft lifecycle reset');

    _isPaused = false;
    _lastUpdateCallback = null;

    Logger.debug('Soft reset completed');
  }

  /// Get lifecycle statistics for monitoring
  ///
  /// Returns detailed statistics about the current lifecycle state
  /// including resource usage and animation status
  static Map<String, dynamic> getStatistics() {
    final state = getState();
    final drivers = AnimationManager.getAllDrivers();
    final activeAnimations = AnimationManager.getActiveAnimations();
    final animatableDrivers = AnimationManager.getAnimatableDrivers();

    return {
      ...state,
      'statistics': {
        'driversTotal': drivers.length,
        'driversAnimatable': animatableDrivers.length,
        'animationsActive': activeAnimations.length,
        'animationUtilization': drivers.isEmpty
            ? 0.0
            : (activeAnimations.length / drivers.length),
        'memoryEfficiency': {
          'iconsCached': IconManager.getCachedIconCount(),
          'availableCarTypes': IconManager.getAvailableCarTypes().length,
        },
      },
    };
  }

  /// Handle app lifecycle state changes
  ///
  /// [state] - The new app lifecycle state
  /// [onUpdateMarker] - Callback function for marker updates (required for resume)
  ///
  /// This method provides a convenient way to handle Flutter's AppLifecycleState
  /// changes automatically.
  static void handleAppLifecycleStateChanged(
    AppLifecycleState state,
    VoidCallback? onUpdateMarker,
  ) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (onUpdateMarker != null) {
          resumeAll(onUpdateMarker);
        } else {
          Logger.warning('Cannot resume: no update callback provided');
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        pauseAll();
        break;
      case AppLifecycleState.detached:
        cleanup();
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state similar to paused
        pauseAll();
        break;
    }
  }

  /// Validate the current lifecycle state
  ///
  /// Returns true if the lifecycle state is consistent and valid
  /// This method can be used for debugging and health checks
  static bool validateState() {
    final state = getState();
    final hasActiveAnimations = state['activeAnimations'] > 0;
    final isPaused = state['isPaused'];

    // If we're paused, we shouldn't have active animations
    if (isPaused && hasActiveAnimations) {
      Logger.warning('Invalid state: paused but has active animations');
      return false;
    }

    // If we have active animations, we should have an update callback
    if (hasActiveAnimations && _lastUpdateCallback == null) {
      Logger.warning('Invalid state: active animations but no update callback');
      return false;
    }

    return true;
  }
}
