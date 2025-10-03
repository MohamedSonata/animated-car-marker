import 'car_asset_model.dart';
import '../constants/animation_constants.dart';

/// Configuration class for AnimatedCarMarkerManager
///
/// This class allows users to customize the behavior and assets of the
/// animated car marker system. Users can provide their own car assets,
/// animation settings, and other configuration options.
///
/// Example usage:
/// ```dart
/// final config = AnimatedCarConfig(
///   carAssets: {
///     'taxi': [CarAssetModel(assetPath: 'assets/my_taxi.png')],
///     'luxury': [CarAssetModel(assetPath: 'assets/my_luxury.png')],
///   },
///   iconSize: 50.0,
///   animationProbability: 30,
/// );
///
/// await AnimatedCarMarkerManager.initialize(config: config);
/// ```
class AnimatedCarConfig {
  /// Custom car assets provided by the user
  ///
  /// Maps car type identifiers to lists of CarAssetModel objects.
  /// If null, the system will use default fallback assets.
  final Map<String, List<CarAssetModel>>? carAssets;

  /// Size of the car icons in logical pixels
  final double iconSize;

  /// Probability percentage that a car will be selected for animation (0-100)
  final int animationProbability;

  /// Default smoothing factor for animations
  final double defaultSmoothingFactor;

  /// Whether to preload icons during initialization
  final bool preloadIcons;

  /// Creates a new animated car configuration
  ///
  /// [carAssets] - Custom car assets (optional, uses defaults if null)
  /// [iconSize] - Size of car icons in logical pixels (default: 40.0)
  /// [animationProbability] - Animation probability 0-100 (default: 20)
  /// [defaultSmoothingFactor] - Default smoothing factor (default: 0.25)
  /// [preloadIcons] - Whether to preload icons (default: true)
  const AnimatedCarConfig({
    this.carAssets,
    this.iconSize = 40.0,
    this.animationProbability = 20,
    this.defaultSmoothingFactor = 0.25,
    this.preloadIcons = true,
  });

  /// Creates a default configuration with fallback assets
  ///
  /// This factory constructor creates a configuration using the default
  /// fallback assets defined in AnimationConstants.
  factory AnimatedCarConfig.withDefaults({
    double iconSize = 40.0,
    int animationProbability = 20,
    double defaultSmoothingFactor = 0.25,
    bool preloadIcons = true,
  }) {
    // Convert default string assets to CarAssetModel
    final defaultAssets = <String, List<CarAssetModel>>{};
    for (final entry in AnimationConstants.defaultCarsAssets.entries) {
      defaultAssets[entry.key] = entry.value
          .map((path) => CarAssetModel.fromPath(path))
          .toList();
    }

    return AnimatedCarConfig(
      carAssets: defaultAssets,
      iconSize: iconSize,
      animationProbability: animationProbability,
      defaultSmoothingFactor: defaultSmoothingFactor,
      preloadIcons: preloadIcons,
    );
  }

  /// Gets the effective car assets (user-provided or defaults)
  ///
  /// Returns the user-provided assets if available, otherwise returns
  /// the default fallback assets converted to CarAssetModel format.
  Map<String, List<CarAssetModel>> getEffectiveCarAssets() {
    if (carAssets != null) {
      return carAssets!;
    }

    // Convert default string assets to CarAssetModel
    final defaultAssets = <String, List<CarAssetModel>>{};
    for (final entry in AnimationConstants.defaultCarsAssets.entries) {
      defaultAssets[entry.key] = entry.value
          .map((path) => CarAssetModel.fromPath(path))
          .toList();
    }
    return defaultAssets;
  }

  /// Gets all available car types from the configuration
  List<String> getAvailableCarTypes() {
    return getEffectiveCarAssets().keys.toList();
  }

  /// Gets the first asset for a specific car type
  ///
  /// Returns the first CarAssetModel for the given car type, or null
  /// if the car type is not found.
  CarAssetModel? getFirstAssetForType(String carType) {
    final assets = getEffectiveCarAssets()[carType];
    return assets?.isNotEmpty == true ? assets!.first : null;
  }

  /// Creates a copy of this configuration with updated values
  AnimatedCarConfig copyWith({
    Map<String, List<CarAssetModel>>? carAssets,
    double? iconSize,
    int? animationProbability,
    double? defaultSmoothingFactor,
    bool? preloadIcons,
  }) {
    return AnimatedCarConfig(
      carAssets: carAssets ?? this.carAssets,
      iconSize: iconSize ?? this.iconSize,
      animationProbability: animationProbability ?? this.animationProbability,
      defaultSmoothingFactor: defaultSmoothingFactor ?? this.defaultSmoothingFactor,
      preloadIcons: preloadIcons ?? this.preloadIcons,
    );
  }

  /// Validates the configuration
  ///
  /// Checks if the configuration is valid and throws an exception
  /// if any issues are found.
  void validate() {
    if (iconSize <= 0) {
      throw ArgumentError('iconSize must be greater than 0');
    }

    if (animationProbability < 0 || animationProbability > 100) {
      throw ArgumentError('animationProbability must be between 0 and 100');
    }

    if (defaultSmoothingFactor < 0.01 || defaultSmoothingFactor > 1.0) {
      throw ArgumentError('defaultSmoothingFactor must be between 0.01 and 1.0');
    }

    final effectiveAssets = getEffectiveCarAssets();
    if (effectiveAssets.isEmpty) {
      throw ArgumentError('At least one car type must be configured');
    }

    // Validate that all car types have at least one asset
    for (final entry in effectiveAssets.entries) {
      if (entry.value.isEmpty) {
        throw ArgumentError('Car type "${entry.key}" must have at least one asset');
      }
    }
  }

  @override
  String toString() {
    return 'AnimatedCarConfig('
        'carTypes: ${getAvailableCarTypes()}, '
        'iconSize: $iconSize, '
        'animationProbability: $animationProbability, '
        'defaultSmoothingFactor: $defaultSmoothingFactor, '
        'preloadIcons: $preloadIcons'
        ')';
  }
}