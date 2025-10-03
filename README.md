# Animated Car Marker

A Flutter package for creating smooth animated car markers on Google Maps. This package provides easy-to-use APIs for managing animated car markers with rotation, lifecycle management, and performance optimization.

## Features

- 🚗 **Smooth rotation animations** for car markers on Google Maps
- 🎯 **Multiple car types** with automatic icon loading and caching
- ⚡ **Performance optimized** for handling multiple animated markers
- 🔄 **Lifecycle management** with pause/resume functionality
- 🎛️ **Customizable animations** with smoothness and speed controls
- 📊 **Debug and monitoring** tools for animation statistics
- 🧹 **Clean API** with comprehensive documentation and error handling
## Demo

Here is a quick demo of how the package works:

![A demo of my package's main feature](https://raw.githubusercontent.com/MohamedSonata/animated-car-marker/refs/heads/main/assets/media/demo.gif)

## Installation

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  animated_car_marker: ^0.0.1
  google_maps_flutter: ^2.13.1
```

Then run:

```bash
flutter pub get
```

## Requirements

- Flutter SDK: >=1.17.0
- Dart SDK: ^3.8.1
- Google Maps Flutter plugin: ^2.13.1

## Quick Start

### 1. Import the package

```dart
import 'package:animated_car_marker/animated_car_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
```

### 2. Initialize the manager

```dart
@override
void initState() {
  super.initState();
  _initializeAnimatedMarkers();
}

Future<void> _initializeAnimatedMarkers() async {
  // Initialize with default configuration
  await AnimatedCarMarkerManager.initialize();
  
  // Or initialize with custom configuration
  /*
  final config = AnimatedCarConfig(
    carAssets: {
      'taxi': [CarAssetModel(assetPath: 'assets/my_taxi.png')],
      'luxury': [CarAssetModel(assetPath: 'assets/my_luxury.png')],
    },
    iconSize: 50.0,
    animationProbability: 30,
  );
  await AnimatedCarMarkerManager.initialize(config: config);
  */
}

### 3. Initialize and animate drivers

```dart
// Initialize a driver for animation
AnimatedCarMarkerManager.initializeDriver('driver123');

// Start animation if the driver should animate
if (AnimatedCarMarkerManager.shouldDriverAnimate('driver123')) {
  AnimatedCarMarkerManager.startAnimation('driver123', () {
    _updateDriverMarker('driver123');
  });
}
```

### 4. Create rotated markers

```dart
void _updateDriverMarker(String driverId) {
  final currentAngle = AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
  final carIcon = AnimatedCarMarkerManager.getCarIcon('taxi');
  
  final marker = MarkerRotation.createRotatedMarker(
    markerId: driverId,
    position: driverPosition,
    icon: carIcon,
    rotation: currentAngle,
  );
  
  // Update your map with the new marker
  setState(() {
    _markers.removeWhere((m) => m.markerId.value == driverId);
    _markers.add(marker);
  });
}
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animated_car_marker/animated_car_marker.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }
  
  Future<void> _initializeAnimation() async {
    // Initialize the manager (this also preloads icons by default)
    await AnimatedCarMarkerManager.initialize();
    
    // Initialize driver
    AnimatedCarMarkerManager.initializeDriver('driver123');
    
    // Start animation
    AnimatedCarMarkerManager.startAnimation('driver123', _updateMarker);
  }
  
  void _updateMarker() {
    final angle = AnimatedCarMarkerManager.getCurrentRotationAngle('driver123');
    final icon = AnimatedCarMarkerManager.getCarIcon('taxi');
    
    final marker = MarkerRotation.createRotatedMarker(
      markerId: 'driver123',
      position: LatLng(37.7749, -122.4194),
      icon: icon,
      rotation: angle,
    );
    
    setState(() {
      _markers = {marker};
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Animated Car Markers')),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 14,
        ),
        markers: _markers,
      ),
    );
  }
  
  @override
  void dispose() {
    AnimatedCarMarkerManager.stopAnimation('driver123');
    super.dispose();
  }
}
```

## Configuration

### Default Configuration

The package comes with default car assets and settings that work out of the box:

```dart
// Initialize with defaults
await AnimatedCarMarkerManager.initialize();

// Available default car types: taxi, luxury, suv, mini, bike
final availableTypes = AnimatedCarMarkerManager.getAvailableCarTypes();
```

### Custom Asset Configuration

You can provide your own car assets for a personalized experience:

```dart
final config = AnimatedCarConfig(
  carAssets: {
    'taxi': [
      CarAssetModel(
        assetPath: 'assets/images/taxi_yellow.png',
        displayName: 'Yellow Taxi',
      ),
    ],
    'uber': [
      CarAssetModel(
        assetPath: 'assets/images/uber_black.png',
        displayName: 'Uber Vehicle',
      ),
    ],
    'delivery': [
      CarAssetModel(
        assetPath: 'assets/images/delivery_van.png',
        displayName: 'Delivery Van',
      ),
    ],
  },
  iconSize: 48.0,                    // Size of car icons
  animationProbability: 25,          // 25% of cars will animate
  defaultSmoothingFactor: 0.2,       // Animation smoothness
  preloadIcons: true,                // Preload icons during init
);

await AnimatedCarMarkerManager.initialize(config: config);
```

### Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `carAssets` | `Map<String, List<CarAssetModel>>?` | `null` | Custom car assets (uses defaults if null) |
| `iconSize` | `double` | `40.0` | Size of car icons in logical pixels |
| `animationProbability` | `int` | `20` | Percentage of cars that animate (0-100) |
| `defaultSmoothingFactor` | `double` | `0.25` | Default animation smoothness (0.01-1.0) |
| `preloadIcons` | `bool` | `true` | Whether to preload icons during initialization |

### Multiple Assets Per Car Type

You can provide multiple asset variations for each car type:

```dart
final config = AnimatedCarConfig(
  carAssets: {
    'taxi': [
      CarAssetModel.fromPath('assets/taxi_yellow.png'),
      CarAssetModel.fromPath('assets/taxi_green.png'),
      CarAssetModel.fromPath('assets/taxi_blue.png'),
    ],
  },
);
// Currently uses the first asset, future versions may support random selection
```

## Advanced Usage

### Custom Animation Settings

```dart
// Start animation with custom smoothness
AnimatedCarMarkerManager.startAnimationWithSmoothness(
  'driver123',
  () => _updateMarker(),
  customSmoothness: 0.15, // 0.01 = very smooth, 1.0 = instant
  turboMode: true, // 3x speed multiplier
);

// Set specific rotation targets
AnimatedCarMarkerManager.setRotationTarget('driver123', RotationTarget.maximum);
AnimatedCarMarkerManager.setRotationTarget('driver456', RotationTarget.center);
AnimatedCarMarkerManager.setRotationTarget('driver789', RotationTarget.random);

// Adjust rotation speed
AnimatedCarMarkerManager.setFasterRotation('driver123', speedMultiplier: 2.0);
AnimatedCarMarkerManager.setNormalRotation('driver123');
```

### Lifecycle Management

```dart
class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // Pause animations when app goes to background
        AnimatedCarMarkerManager.pauseAllAnimations();
        break;
      case AppLifecycleState.resumed:
        // Resume animations when app returns to foreground
        AnimatedCarMarkerManager.resumeAllAnimations(() {
          _updateAllMarkers();
        });
        break;
      case AppLifecycleState.detached:
        // Clean up resources when app is closing
        AnimatedCarMarkerManager.clearCache();
        break;
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AnimatedCarMarkerManager.stopAllAnimations();
    super.dispose();
  }
}
```

### Multiple Car Types

```dart
// Get all available car types
final carTypes = AnimatedCarMarkerManager.getAvailableCarTypes();
print('Available car types: $carTypes'); // [taxi, luxury, suv, mini, bike]

// Create markers with different car types
void _createMultipleMarkers() {
  final drivers = [
    {'id': 'taxi1', 'type': 'taxi', 'position': LatLng(37.7749, -122.4194)},
    {'id': 'luxury1', 'type': 'luxury', 'position': LatLng(37.7849, -122.4094)},
    {'id': 'suv1', 'type': 'suv', 'position': LatLng(37.7649, -122.4294)},
  ];
  
  for (final driver in drivers) {
    AnimatedCarMarkerManager.initializeDriver(driver['id'] as String);
    AnimatedCarMarkerManager.startAnimation(driver['id'] as String, () {
      _updateSpecificMarker(driver);
    });
  }
}

void _updateSpecificMarker(Map<String, dynamic> driver) {
  final angle = AnimatedCarMarkerManager.getCurrentRotationAngle(driver['id']);
  final icon = AnimatedCarMarkerManager.getCarIcon(driver['type']);
  
  final marker = MarkerRotation.createRotatedMarker(
    markerId: driver['id'],
    position: driver['position'],
    icon: icon,
    rotation: angle,
  );
  
  setState(() {
    _markers.add(marker);
  });
}
```

### Batch Operations for Performance

```dart
// Batch update multiple drivers for better performance
void _batchUpdateDrivers() {
  final driverIds = ['driver1', 'driver2', 'driver3', 'driver4', 'driver5'];
  
  AnimatedCarMarkerManager.batchUpdateDrivers(driverIds, (updatedDrivers) {
    final newMarkers = <Marker>{};
    
    for (final driverId in updatedDrivers) {
      final angle = AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
      final icon = AnimatedCarMarkerManager.getCarIcon('taxi');
      final position = _getDriverPosition(driverId); // Your position logic
      
      final marker = MarkerRotation.createRotatedMarker(
        markerId: driverId,
        position: position,
        icon: icon,
        rotation: angle,
      );
      
      newMarkers.add(marker);
    }
    
    setState(() {
      _markers = newMarkers;
    });
  });
}
```

### Animation Monitoring and Debugging

```dart
// Get detailed animation statistics
void _printAnimationStats() {
  final stats = AnimatedCarMarkerManager.getAnimationStats('driver123');
  print('Current angle: ${stats['currentAngle']}°');
  print('Target angle: ${stats['targetAngle']}°');
  print('Animation active: ${stats['isActive']}');
  print('Smoothing factor: ${stats['smoothingFactor']}');
  print('Animation ticks: ${stats['animationTicks']}');
}

// Print summary of all animations
AnimatedCarMarkerManager.printAnimationSummary();

// Get lists of active and animatable drivers
final activeAnimations = AnimatedCarMarkerManager.getActiveAnimations();
final animatableDrivers = AnimatedCarMarkerManager.getAnimatableDrivers();
print('Active: $activeAnimations');
print('Animatable: $animatableDrivers');
```

### Performance Optimization Tips

```dart
class OptimizedMapScreen extends StatefulWidget {
  @override
  _OptimizedMapScreenState createState() => _OptimizedMapScreenState();
}

class _OptimizedMapScreenState extends State<OptimizedMapScreen> {
  Timer? _batchUpdateTimer;
  final Set<String> _pendingUpdates = {};
  
  @override
  void initState() {
    super.initState();
    _setupBatchUpdates();
  }
  
  void _setupBatchUpdates() {
    // Batch marker updates every 100ms for better performance
    _batchUpdateTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (_pendingUpdates.isNotEmpty) {
        _processBatchUpdates();
      }
    });
  }
  
  void _onDriverUpdate(String driverId) {
    // Add to pending updates instead of immediate update
    _pendingUpdates.add(driverId);
  }
  
  void _processBatchUpdates() {
    final updates = List<String>.from(_pendingUpdates);
    _pendingUpdates.clear();
    
    final newMarkers = <Marker>{};
    for (final driverId in updates) {
      final angle = AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
      final icon = AnimatedCarMarkerManager.getCarIcon('taxi');
      final position = _getDriverPosition(driverId);
      
      final marker = MarkerRotation.createRotatedMarker(
        markerId: driverId,
        position: position,
        icon: icon,
        rotation: angle,
      );
      
      newMarkers.add(marker);
    }
    
    if (newMarkers.isNotEmpty) {
      setState(() {
        // Update only changed markers
        _markers.removeWhere((m) => updates.contains(m.markerId.value));
        _markers.addAll(newMarkers);
      });
    }
  }
  
  @override
  void dispose() {
    _batchUpdateTimer?.cancel();
    super.dispose();
  }
}
```

### Real-time Driver Updates

```dart
// Example of integrating with real-time location updates
class RealTimeDriverMap extends StatefulWidget {
  @override
  _RealTimeDriverMapState createState() => _RealTimeDriverMapState();
}

class _RealTimeDriverMapState extends State<RealTimeDriverMap> {
  final Map<String, LatLng> _driverPositions = {};
  StreamSubscription? _locationSubscription;
  
  @override
  void initState() {
    super.initState();
    _setupRealTimeUpdates();
  }
  
  void _setupRealTimeUpdates() {
    // Listen to driver location updates from your backend
    _locationSubscription = _driverLocationStream.listen((driverUpdate) {
      final driverId = driverUpdate.driverId;
      final newPosition = driverUpdate.position;
      
      // Update position
      _driverPositions[driverId] = newPosition;
      
      // Initialize driver if not exists
      if (!AnimatedCarMarkerManager.getAllDrivers().containsKey(driverId)) {
        AnimatedCarMarkerManager.initializeDriver(driverId);
        
        // Start animation if driver should animate
        if (AnimatedCarMarkerManager.shouldDriverAnimate(driverId)) {
          AnimatedCarMarkerManager.startAnimation(driverId, () {
            _updateDriverMarker(driverId);
          });
        }
      }
      
      // Update marker immediately for position change
      _updateDriverMarker(driverId);
    });
  }
  
  void _updateDriverMarker(String driverId) {
    final position = _driverPositions[driverId];
    if (position == null) return;
    
    final angle = AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
    final icon = AnimatedCarMarkerManager.getCarIcon('taxi');
    
    final marker = MarkerRotation.createRotatedMarker(
      markerId: driverId,
      position: position,
      icon: icon,
      rotation: angle,
      onTap: () => _onDriverTapped(driverId),
      infoWindow: InfoWindow(
        title: 'Driver $driverId',
        snippet: 'Angle: ${angle.toStringAsFixed(1)}°',
      ),
    );
    
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == driverId);
      _markers.add(marker);
    });
  }
  
  void _onDriverTapped(String driverId) {
    // Show driver details or toggle animation
    final isActive = AnimatedCarMarkerManager.isAnimationActive(driverId);
    if (isActive) {
      AnimatedCarMarkerManager.stopAnimation(driverId);
    } else {
      AnimatedCarMarkerManager.startAnimation(driverId, () {
        _updateDriverMarker(driverId);
      });
    }
  }
  
  @override
  void dispose() {
    _locationSubscription?.cancel();
    AnimatedCarMarkerManager.stopAllAnimations();
    super.dispose();
  }
}
```## API 
Reference

### Core Classes

- **`AnimatedCarMarkerManager`**: Main API class for managing animated car markers
- **`MarkerRotation`**: Extension for creating rotated markers
- **`RotationTarget`**: Enum for different rotation target types

### Available Car Types

- `taxi` - Standard taxi icon
- `luxury` - Luxury car icon  
- `suv` - SUV icon
- `mini` - Mini car icon
- `bike` - Bike/motorcycle icon

### Rotation Targets

- `RotationTarget.maximum` - Rotate to maximum allowed angle
- `RotationTarget.minimum` - Subtle rotation movements
- `RotationTarget.random` - Random angle within limits (default)
- `RotationTarget.center` - Return to neutral position (0°)

## Migration Guide

If you're upgrading from a previous version, this section will help you migrate to the new flexible asset configuration system.

### What Changed

#### Before (Old System)
- Assets were hardcoded in `AnimationConstants.carsAssets`
- Users couldn't provide their own custom assets
- All car types used the same default asset
- No configuration options for animation behavior

#### After (New System)
- Flexible asset configuration through `AnimatedCarConfig`
- Users can provide custom assets via `CarAssetModel`
- Default fallback assets still available
- Configurable animation parameters
- **Proper initialization required**

### Migration Steps

#### Step 1: Update Initialization

**Old Code:**
```dart
// Old way - no initialization needed
AnimatedCarMarkerManager.initializeDriver('driver123');
AnimatedCarMarkerManager.startAnimation('driver123', updateCallback);
```

**New Code:**
```dart
// New way - initialization required
await AnimatedCarMarkerManager.initialize(); // Add this line
AnimatedCarMarkerManager.initializeDriver('driver123');
AnimatedCarMarkerManager.startAnimation('driver123', updateCallback);
```

#### Step 2: Custom Assets (Optional)

If you want to use your own assets instead of the defaults:

```dart
// Create custom configuration
final config = AnimatedCarConfig(
  carAssets: {
    'taxi': [
      CarAssetModel(
        assetPath: 'assets/images/my_taxi.png',
        displayName: 'Yellow Taxi',
      ),
    ],
    'luxury': [
      CarAssetModel(
        assetPath: 'assets/images/my_luxury_car.png',
        displayName: 'Luxury Vehicle',
      ),
    ],
    'delivery': [
      CarAssetModel(
        assetPath: 'assets/images/delivery_van.png',
        displayName: 'Delivery Van',
      ),
    ],
  },
  iconSize: 50.0,
  animationProbability: 30, // 30% of cars will animate
  defaultSmoothingFactor: 0.2,
);

// Initialize with custom configuration
await AnimatedCarMarkerManager.initialize(config: config);
```

#### Step 3: Update Imports

Add the new model imports if you're using custom configuration:

```dart
import 'package:animated_car_marker/animated_car_marker.dart';

// These are now available:
// - AnimatedCarConfig
// - CarAssetModel
// - RotationTarget (existing)
```

### Breaking Changes

1. **Initialization Required**: You must call `AnimatedCarMarkerManager.initialize()` before using other methods
2. **Error Handling**: Methods now throw `StateError` if not initialized
3. **Asset Structure**: `AnimationConstants.carsAssets` renamed to `AnimationConstants.defaultCarsAssets`

### Benefits of New System

1. **Flexibility**: Use your own custom car assets
2. **Configuration**: Customize animation behavior per app
3. **Type Safety**: Proper models for asset management
4. **Extensibility**: Easy to add new car types and assets
5. **Performance**: Better control over preloading and caching
6. **Maintainability**: Cleaner separation of concerns

### Migration Examples

#### Example 1: Minimal Migration (Default Configuration)
```dart
class MyMapWidget extends StatefulWidget {
  @override
  _MyMapWidgetState createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  Future<void> _initializeAnimations() async {
    // Use default configuration - just add this line
    await AnimatedCarMarkerManager.initialize();
    
    // Rest of your existing code works the same...
  }
}
```

#### Example 2: Custom Assets Migration
```dart
Future<void> _initializeWithCustomAssets() async {
  final config = AnimatedCarConfig(
    carAssets: {
      'taxi': [
        CarAssetModel.fromPath('assets/taxi_yellow.png'),
        CarAssetModel.fromPath('assets/taxi_green.png'),
      ],
      'uber': [
        CarAssetModel(
          assetPath: 'assets/uber_black.png',
          displayName: 'Uber Vehicle',
          metadata: {'service': 'uber', 'color': 'black'},
        ),
      ],
    },
    iconSize: 48.0,
    animationProbability: 25,
  );

  await AnimatedCarMarkerManager.initialize(config: config);
}
```

### Migration Troubleshooting

#### Common Migration Issues

**Issue**: `StateError: AnimatedCarMarkerManager not initialized`
**Solution**: Call `await AnimatedCarMarkerManager.initialize()` before using other methods

**Issue**: Custom assets not loading
**Solution**: Ensure asset paths are correct and assets are included in `pubspec.yaml`

**Issue**: No cars animating after migration
**Solution**: Check `animationProbability` in your configuration (should be > 0)

#### Validation

The new system includes validation to catch configuration errors early:

```dart
try {
  await AnimatedCarMarkerManager.initialize(config: config);
} catch (e) {
  print('Configuration error: $e');
  // Handle configuration issues
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Markers not appearing on map

**Problem**: Markers are not visible on the Google Map.

**Solutions**:
```dart
// Ensure icons are preloaded before creating markers
await AnimatedCarMarkerManager.preloadCarIcons();

// Check if marker creation is successful
final marker = MarkerRotation.createRotatedMarker(
  markerId: 'driver123',
  position: LatLng(37.7749, -122.4194), // Valid coordinates
  icon: AnimatedCarMarkerManager.getCarIcon('taxi'),
  rotation: 0.0,
);

// Verify marker is added to the set
setState(() {
  _markers = {marker}; // Make sure this triggers a rebuild
});
```

#### 2. Animation not starting

**Problem**: Car markers are not rotating even after calling `startAnimation`.

**Solutions**:
```dart
// Check if driver is initialized
AnimatedCarMarkerManager.initializeDriver('driver123');

// Verify driver should animate (not all drivers animate by design)
if (AnimatedCarMarkerManager.shouldDriverAnimate('driver123')) {
  AnimatedCarMarkerManager.startAnimation('driver123', () {
    _updateMarker();
  });
} else {
  print('Driver is not set to animate');
}

// Check animation status
final isActive = AnimatedCarMarkerManager.isAnimationActive('driver123');
print('Animation active: $isActive');
```

#### 3. Poor performance with many markers

**Problem**: App becomes slow when animating many markers.

**Solutions**:
```dart
// Use batch updates instead of individual updates
AnimatedCarMarkerManager.batchUpdateDrivers(driverIds, (updatedDrivers) {
  // Update only changed markers
});

// Limit the number of animated drivers
final animatableDrivers = AnimatedCarMarkerManager.getAnimatableDrivers();
if (animatableDrivers.length > 10) {
  // Stop some animations or reduce update frequency
}

// Use a timer to batch UI updates
Timer.periodic(Duration(milliseconds: 200), (_) {
  // Update markers less frequently
});
```

#### 4. Memory leaks

**Problem**: App memory usage increases over time.

**Solutions**:
```dart
// Always stop animations when disposing
@override
void dispose() {
  AnimatedCarMarkerManager.stopAllAnimations();
  AnimatedCarMarkerManager.clearCache();
  super.dispose();
}

// Pause animations when app goes to background
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    AnimatedCarMarkerManager.pauseAllAnimations();
  }
}
```

#### 5. Icons not loading

**Problem**: Car icons appear as default markers instead of custom icons.

**Solutions**:
```dart
// Ensure assets are properly configured in pubspec.yaml
flutter:
  assets:
    - assets/images/cars/

// Check if preloading completed successfully
try {
  await AnimatedCarMarkerManager.preloadCarIcons();
  print('Icons preloaded successfully');
} catch (e) {
  print('Icon preloading failed: $e');
  // The package will fall back to colored markers
}

// Verify car type is valid
final availableTypes = AnimatedCarMarkerManager.getAvailableCarTypes();
print('Available car types: $availableTypes');
```

### Performance Optimization Tips

#### 1. Preload Icons Early
```dart
// Preload during app initialization, not during map creation
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AnimatedCarMarkerManager.preloadCarIcons(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(home: MapScreen());
        }
        return MaterialApp(home: LoadingScreen());
      },
    );
  }
}
```

#### 2. Optimize Update Frequency
```dart
// Reduce animation frequency for better performance
class _MapScreenState extends State<MapScreen> {
  Timer? _updateTimer;
  
  void _startOptimizedUpdates() {
    _updateTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
      // Update markers every 200ms instead of 100ms
      _updateAllMarkers();
    });
  }
}
```

#### 3. Limit Concurrent Animations
```dart
// Limit the number of simultaneously animated drivers
void _manageAnimationLoad() {
  final activeAnimations = AnimatedCarMarkerManager.getActiveAnimations();
  
  if (activeAnimations.length > 15) {
    // Stop some animations to maintain performance
    for (int i = 10; i < activeAnimations.length; i++) {
      AnimatedCarMarkerManager.stopAnimation(activeAnimations[i]);
    }
  }
}
```

#### 4. Use Efficient State Management
```dart
// Only update changed markers, not all markers
void _efficientMarkerUpdate(String driverId) {
  final angle = AnimatedCarMarkerManager.getCurrentRotationAngle(driverId);
  final icon = AnimatedCarMarkerManager.getCarIcon('taxi');
  
  final newMarker = MarkerRotation.createRotatedMarker(
    markerId: driverId,
    position: _getDriverPosition(driverId),
    icon: icon,
    rotation: angle,
  );
  
  setState(() {
    // Remove old marker and add new one
    _markers.removeWhere((m) => m.markerId.value == driverId);
    _markers.add(newMarker);
  });
}
```

### Debugging Methods

#### 1. Animation Statistics
```dart
// Get detailed animation information
void _debugAnimation(String driverId) {
  final stats = AnimatedCarMarkerManager.getAnimationStats(driverId);
  
  print('=== Animation Debug Info ===');
  print('Driver ID: $driverId');
  print('Current Angle: ${stats['currentAngle']}°');
  print('Target Angle: ${stats['targetAngle']}°');
  print('Is Active: ${stats['isActive']}');
  print('Should Animate: ${stats['shouldAnimate']}');
  print('Smoothing Factor: ${stats['smoothingFactor']}');
  print('Animation Ticks: ${stats['animationTicks']}');
  print('Target Type: ${stats['currentTargetType']}');
}
```

#### 2. System Overview
```dart
// Print comprehensive system status
void _debugSystem() {
  print('\n=== System Debug Info ===');
  
  // Print animation summary
  AnimatedCarMarkerManager.printAnimationSummary();
  
  // Get all drivers
  final allDrivers = AnimatedCarMarkerManager.getAllDrivers();
  print('Total drivers: ${allDrivers.length}');
  
  // Check available car types
  final carTypes = AnimatedCarMarkerManager.getAvailableCarTypes();
  print('Available car types: $carTypes');
  
  // Memory usage info
  print('Active animations: ${AnimatedCarMarkerManager.getActiveAnimations().length}');
  print('Animatable drivers: ${AnimatedCarMarkerManager.getAnimatableDrivers().length}');
}
```

#### 3. Performance Monitoring
```dart
// Monitor performance metrics
class PerformanceMonitor {
  static int _updateCount = 0;
  static DateTime _lastReset = DateTime.now();
  
  static void recordUpdate() {
    _updateCount++;
    
    final now = DateTime.now();
    if (now.difference(_lastReset).inSeconds >= 10) {
      final updatesPerSecond = _updateCount / 10;
      print('Marker updates per second: ${updatesPerSecond.toStringAsFixed(1)}');
      
      _updateCount = 0;
      _lastReset = now;
    }
  }
}

// Use in your update callback
void _updateMarkerWithMonitoring() {
  PerformanceMonitor.recordUpdate();
  _updateMarker();
}
```

## FAQ

### Q: How many markers can I animate simultaneously?
**A**: The package is optimized for 10-20 simultaneously animated markers. Beyond this, consider using batch updates and reducing animation frequency for better performance.

### Q: Can I use custom car icons?
**A**: Currently, the package uses predefined car types. Custom icons can be added by modifying the `AnimationConstants.carsAssets` configuration and rebuilding the package.

### Q: Why don't all drivers animate?
**A**: By design, only a percentage of drivers are set to animate (based on `AnimationConstants.animationProbability`). This maintains visual balance and performance.

### Q: How do I stop all animations at once?
**A**: Use `AnimatedCarMarkerManager.stopAllAnimations()` to stop all active animations and clean up resources.

### Q: Can I change animation speed for individual drivers?
**A**: Yes, use `setFasterRotation()` with a speed multiplier or `startAnimationWithSmoothness()` with custom parameters.

### Q: How do I handle app lifecycle events?
**A**: Implement `WidgetsBindingObserver` and use `pauseAllAnimations()` and `resumeAllAnimations()` in the appropriate lifecycle methods.

### Q: What happens if icon loading fails?
**A**: The package gracefully falls back to colored default markers, ensuring functionality continues even if custom assets fail to load.

### Q: How do I optimize for battery usage?
**A**: Reduce animation frequency, limit concurrent animations, and always pause animations when the app goes to background.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Review the example code in this README
3. Open an issue on GitHub with detailed information about your problem

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and version history.