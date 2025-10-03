import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Extension for creating rotated markers with enhanced functionality.
///
/// This extension provides utility methods for creating Google Maps markers
/// with rotation support, optimized for smooth animation and proper anchoring.
///
/// Example usage:
/// ```dart
/// final marker = MarkerRotation.createRotatedMarker(
///   markerId: 'driver_123',
///   position: LatLng(37.7749, -122.4194),
///   icon: carIcon,
///   rotation: 45.0,
///   infoWindow: InfoWindow(title: 'Driver Location'),
/// );
/// ```
extension MarkerRotation on Marker {
  /// Creates a rotated marker with the specified parameters.
  ///
  /// This method creates a Google Maps [Marker] with rotation support,
  /// using a centered anchor point for smooth rotation animations.
  ///
  /// Parameters:
  /// - [markerId]: Unique identifier for the marker (required)
  /// - [position]: Geographic position of the marker (required)
  /// - [icon]: Bitmap descriptor for the marker icon (required)
  /// - [rotation]: Rotation angle in degrees (default: 0.0)
  /// - [infoWindow]: Info window to display when marker is tapped (default: no text)
  /// - [onTap]: Callback function when marker is tapped (optional)
  ///
  /// Returns:
  /// A configured [Marker] instance with rotation and centered anchoring.
  ///
  /// The marker uses a center anchor (0.5, 0.5) to ensure smooth rotation
  /// around the marker's center point, which is essential for animated
  /// car markers that change direction.
  static Marker createRotatedMarker({
    required String markerId,
    required LatLng position,
    required BitmapDescriptor icon,
    double rotation = 0.0,
    InfoWindow infoWindow = InfoWindow.noText,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: icon,
      rotation: rotation,
      infoWindow: infoWindow,
      onTap: onTap,
      anchor: const Offset(0.5, 0.5), // Center anchor for smooth rotation
    );
  }
}
