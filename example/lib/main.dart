import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animated_car_marker/animated_car_marker.dart';

/// Example demonstrating how to use AnimatedCarMarkerManager with custom assets
class CustomAssetsExample extends StatefulWidget {
  const CustomAssetsExample({super.key});

  @override
  State<CustomAssetsExample> createState() => _CustomAssetsExampleState();
}

class _CustomAssetsExampleState extends State<CustomAssetsExample> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimatedMarkers();
  }

  /// Initialize the animated car marker system with custom assets
  Future<void> _initializeAnimatedMarkers() async {
    try {
      // Option 1: Use default configuration
      await AnimatedCarMarkerManager.initialize();

      // Option 2: Use custom configuration with your own assets
      /*
      final customConfig = AnimatedCarConfig(
        carAssets: {
          'taxi': [
            CarAssetModel(
              assetPath: 'assets/images/taxi_yellow.png',
              displayName: 'Yellow Taxi',
            ),
            CarAssetModel(
              assetPath: 'assets/images/taxi_green.png',
              displayName: 'Green Taxi',
            ),
          ],
          'luxury': [
            CarAssetModel(
              assetPath: 'assets/images/luxury_black.png',
              displayName: 'Black Luxury Car',
            ),
          ],
          'delivery': [
            CarAssetModel(
              assetPath: 'assets/images/delivery_van.png',
              displayName: 'Delivery Van',
            ),
          ],
        },
        iconSize: 48.0,
        animationProbability: 25, // 25% of cars will animate
        defaultSmoothingFactor: 0.2,
      );

      await AnimatedCarMarkerManager.initialize(config: customConfig);
      */

      setState(() {
        _isInitialized = true;
      });

      // Initialize some sample drivers
      _initializeSampleDrivers();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize animated markers: $e');
      }
    }
  }

  /// Initialize sample drivers with different car types
  void _initializeSampleDrivers() {
    final sampleDrivers = [
      {'id': 'driver_001', 'type': 'taxi', 'lat': 37.7749, 'lng': -122.4194},
      {'id': 'driver_002', 'type': 'luxury', 'lat': 37.7849, 'lng': -122.4094},
      {'id': 'driver_003', 'type': 'suv', 'lat': 37.7649, 'lng': -122.4294},
    ];

    for (final driver in sampleDrivers) {
      final driverId = driver['id'] as String;
      final carType = driver['type'] as String;
      final lat = driver['lat'] as double;
      final lng = driver['lng'] as double;

      // Initialize driver for animation
      AnimatedCarMarkerManager.initializeDriver(driverId);

      // Create initial marker
      _updateDriverMarker(driverId, carType, LatLng(lat, lng));

      // Start animation if driver should animate
      if (AnimatedCarMarkerManager.shouldDriverAnimate(driverId)) {
        AnimatedCarMarkerManager.startAnimation(driverId, () {
          _updateDriverMarker(driverId, carType, LatLng(lat, lng));
        });
      }
    }
  }

  /// Update a driver's marker with current rotation
  void _updateDriverMarker(String driverId, String carType, LatLng position) {
    final currentAngle = AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
    final carIcon = AnimatedCarMarkerManager.getCarIcon(carType);

    final marker = MarkerRotation.createRotatedMarker(
      markerId: driverId,
      position: position,
      icon: carIcon,
      rotation: currentAngle,
      infoWindow: InfoWindow(
        title: 'Driver $driverId',
        snippet: 'Car Type: $carType, Angle: ${currentAngle.toStringAsFixed(1)}°',
      ),
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == driverId);
      _markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Assets Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showAvailableCarTypes,
          ),
        ],
      ),
      body: _isInitialized
          ? GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // San Francisco
                zoom: 12,
              ),
              markers: _markers,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
              onPressed: _showAnimationStats,
              child: const Icon(Icons.analytics),
            )
          : null,
    );
  }

  /// Show available car types in the current configuration
  void _showAvailableCarTypes() {
    final availableTypes = AnimatedCarMarkerManager.getAvailableCarTypes();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Car Types'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: availableTypes
              .map((type) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $type'),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show animation statistics for all drivers
  void _showAnimationStats() {
    final activeAnimations = AnimatedCarMarkerManager.getActiveAnimations();
    final animatableDrivers = AnimatedCarMarkerManager.getAnimatableDrivers();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Animation Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total animatable drivers: ${animatableDrivers.length}'),
            Text('Active animations: ${activeAnimations.length}'),
            const SizedBox(height: 16),
            const Text('Animatable drivers:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...animatableDrivers.map((id) => Text('• $id')),
            const SizedBox(height: 8),
            const Text('Active animations:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...activeAnimations.map((id) => Text('• $id')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up animations when widget is disposed
    AnimatedCarMarkerManager.stopAllAnimations();
    super.dispose();
  }
}