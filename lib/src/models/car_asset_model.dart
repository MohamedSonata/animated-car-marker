/// Model representing a car asset with its path and optional metadata
///
/// This model encapsulates information about car assets including the asset path,
/// optional display name, and any additional metadata that might be useful
/// for the animation system.
///
/// Example usage:
/// ```dart
/// final taxiAsset = CarAssetModel(
///   assetPath: 'assets/images/cars/taxi.png',
///   displayName: 'Yellow Taxi',
/// );
///
/// final luxuryAsset = CarAssetModel(
///   assetPath: 'assets/images/cars/luxury.png',
///   displayName: 'Luxury Car',
///   metadata: {'color': 'black', 'size': 'large'},
/// );
/// ```
class CarAssetModel {
  /// The path to the asset file
  final String assetPath;

  /// Optional display name for the car asset
  final String? displayName;

  /// Optional metadata for additional asset information
  final Map<String, dynamic>? metadata;

  /// Creates a new car asset model
  ///
  /// [assetPath] is required and should be a valid asset path
  /// [displayName] is optional and can be used for UI display
  /// [metadata] is optional and can store additional asset information
  const CarAssetModel({
    required this.assetPath,
    this.displayName,
    this.metadata,
  });

  /// Creates a car asset model from a simple string path
  ///
  /// This factory constructor provides a convenient way to create
  /// a CarAssetModel from just an asset path string.
  ///
  /// Example:
  /// ```dart
  /// final asset = CarAssetModel.fromPath('assets/images/cars/taxi.png');
  /// ```
  factory CarAssetModel.fromPath(String assetPath) {
    return CarAssetModel(assetPath: assetPath);
  }

  /// Creates a copy of this model with updated values
  ///
  /// Allows creating a new instance with some fields updated while
  /// keeping others unchanged.
  ///
  /// Example:
  /// ```dart
  /// final updatedAsset = originalAsset.copyWith(
  ///   displayName: 'New Display Name',
  /// );
  /// ```
  CarAssetModel copyWith({
    String? assetPath,
    String? displayName,
    Map<String, dynamic>? metadata,
  }) {
    return CarAssetModel(
      assetPath: assetPath ?? this.assetPath,
      displayName: displayName ?? this.displayName,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts the model to a map representation
  ///
  /// Useful for serialization or debugging purposes.
  Map<String, dynamic> toMap() {
    return {
      'assetPath': assetPath,
      'displayName': displayName,
      'metadata': metadata,
    };
  }

  /// Creates a CarAssetModel from a map
  ///
  /// Useful for deserialization from JSON or other map-based data sources.
  ///
  /// Example:
  /// ```dart
  /// final map = {
  ///   'assetPath': 'assets/images/cars/taxi.png',
  ///   'displayName': 'Yellow Taxi',
  /// };
  /// final asset = CarAssetModel.fromMap(map);
  /// ```
  factory CarAssetModel.fromMap(Map<String, dynamic> map) {
    return CarAssetModel(
      assetPath: map['assetPath'] as String,
      displayName: map['displayName'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarAssetModel &&
        other.assetPath == assetPath &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return assetPath.hashCode ^ displayName.hashCode;
  }

  @override
  String toString() {
    return 'CarAssetModel(assetPath: $assetPath, displayName: $displayName)';
  }
}