import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/logger.dart';
import '../models/car_asset_model.dart';
import '../models/animated_car_config.dart';

/// Manager class responsible for icon loading and caching functionality
///
/// This class handles all icon-related operations including:
/// - Preloading car icons for different types
/// - Caching loaded icons for performance
/// - Providing fallback icons when assets fail to load
/// - Managing icon cache lifecycle
/// - Supporting user-provided custom assets
class IconManager {
  static final Map<String, BitmapDescriptor> _iconCache = {};
  static AnimatedCarConfig? _currentConfig;

  /// Initialize the IconManager with configuration
  ///
  /// [config] - The configuration containing car assets and settings
  ///
  /// This method must be called before using other IconManager methods.
  /// It sets up the configuration and optionally preloads icons.
  static Future<void> initialize(AnimatedCarConfig config) async {
    config.validate();
    _currentConfig = config;

    if (config.preloadIcons) {
      await preloadIcons(size: config.iconSize);
    }

    Logger.info('IconManager initialized with ${config.getAvailableCarTypes().length} car types');
  }

  /// Preload all car icons for different types
  ///
  /// [size] - The size of the icons to load (uses config size if not specified)
  ///
  /// This method loads all car icons defined in the current configuration
  /// and caches them for later use. If an asset fails to load, a fallback
  /// colored marker is used instead.
  static Future<void> preloadIcons({double? size}) async {
    if (_currentConfig == null) {
      throw StateError('IconManager not initialized. Call initialize() first.');
    }

    final iconSize = size ?? _currentConfig!.iconSize;
    final carAssets = _currentConfig!.getEffectiveCarAssets();
    final List<Future<void>> loadingFutures = [];

    for (String carType in carAssets.keys) {
      final assets = carAssets[carType]!;
      for (CarAssetModel asset in assets) {
        if (!_iconCache.containsKey(asset.assetPath)) {
          loadingFutures.add(_loadSingleIcon(asset, iconSize, carType));
        }
      }
    }

    await Future.wait(loadingFutures);
    Logger.info(
      'Preloaded ${_iconCache.length} car icons for ${carAssets.length} car types',
    );
  }

  /// Load a single icon with proper caching and error handling
  ///
  /// [asset] - The CarAssetModel containing asset information
  /// [size] - The size of the icon to load
  /// [carType] - The car type for fallback color selection
  ///
  /// This method attempts to load an icon from the given asset.
  /// If loading fails, it creates a fallback colored marker based on the car type.
  static Future<void> _loadSingleIcon(CarAssetModel asset, double size, String carType) async {
    try {
      final icon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(size, size)),
        asset.assetPath,
      );
      _iconCache[asset.assetPath] = icon;
      Logger.debug('Successfully loaded icon: ${asset.assetPath}');
    } catch (e) {
      Logger.error('Failed to load car icon ${asset.assetPath}', e);
      // Use a fallback icon with different colors based on car type
      final hue = _getHueForCarType(carType);
      _iconCache[asset.assetPath] = BitmapDescriptor.defaultMarkerWithHue(hue);
      Logger.info('Using fallback colored marker for $carType (${asset.assetPath})');
    }
  }



  /// Get hue color for car type
  ///
  /// [carType] - The type of car to get the hue for
  /// Returns a hue value that corresponds to the car type for fallback markers
  static double _getHueForCarType(String carType) {
    switch (carType) {
      case 'taxi':
        return BitmapDescriptor.hueYellow;
      case 'luxury':
        return BitmapDescriptor.hueBlue;
      case 'suv':
        return BitmapDescriptor.hueGreen;
      case 'mini':
        return BitmapDescriptor.hueOrange;
      case 'bike':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueYellow;
    }
  }

  /// Get icon for specific car type
  ///
  /// [carType] - The type of car to get the icon for
  /// Returns the cached BitmapDescriptor for the given car type
  ///
  /// If no icon is cached for the car type, returns a fallback colored marker.
  /// This method is safe to call even if preloadIcons hasn't been called.
  static BitmapDescriptor getIcon(String carType) {
    if (_currentConfig == null) {
      Logger.warning('IconManager not initialized, using default marker');
      return BitmapDescriptor.defaultMarkerWithHue(_getHueForCarType(carType));
    }

    final carAssets = _currentConfig!.getEffectiveCarAssets();
    final assets = carAssets[carType];
    
    if (assets == null || assets.isEmpty) {
      Logger.warning('No assets found for car type $carType, using default');
      return BitmapDescriptor.defaultMarkerWithHue(_getHueForCarType(carType));
    }

    // Use the first asset in the list
    // You can extend this to support multiple assets per type or random selection
    final asset = assets.first;
    final icon = _iconCache[asset.assetPath];

    if (icon == null) {
      Logger.warning('Icon not cached for ${asset.assetPath}, using default');
      return BitmapDescriptor.defaultMarkerWithHue(_getHueForCarType(carType));
    }

    return icon;
  }

  /// Clear all cached icons
  ///
  /// This method removes all cached icons from memory.
  /// Useful for memory management and when the app needs to free resources.
  static void clearIconCache() {
    _iconCache.clear();
    Logger.info('Icon cache cleared');
  }

  /// Get the number of cached icons
  ///
  /// Returns the current number of icons stored in the cache.
  /// Useful for debugging and monitoring memory usage.
  static int getCachedIconCount() {
    return _iconCache.length;
  }

  /// Check if an icon is cached for a specific car type
  ///
  /// [carType] - The car type to check
  /// Returns true if an icon is cached for the given car type
  static bool isIconCached(String carType) {
    if (_currentConfig == null) {
      return false;
    }

    final carAssets = _currentConfig!.getEffectiveCarAssets();
    final assets = carAssets[carType];
    if (assets == null || assets.isEmpty) {
      return false;
    }

    final assetPath = assets.first.assetPath;
    return _iconCache.containsKey(assetPath);
  }

  /// Get all available car types
  ///
  /// Returns a list of all car types that have assets defined.
  /// This is useful for UI components that need to display available options.
  static List<String> getAvailableCarTypes() {
    if (_currentConfig == null) {
      Logger.warning('IconManager not initialized, returning empty list');
      return [];
    }
    return _currentConfig!.getAvailableCarTypes();
  }

  /// Get the current configuration
  ///
  /// Returns the current AnimatedCarConfig or null if not initialized.
  static AnimatedCarConfig? getCurrentConfig() {
    return _currentConfig;
  }

  /// Check if IconManager is initialized
  ///
  /// Returns true if the IconManager has been initialized with a configuration.
  static bool get isInitialized => _currentConfig != null;
}
