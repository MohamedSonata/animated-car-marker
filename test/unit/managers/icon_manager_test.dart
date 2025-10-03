import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/src/managers/icon_manager.dart';

/// Unit tests for IconManager class
/// 
/// Tests icon loading, caching, and fallback functionality.
void main() {
  group('IconManager Unit Tests', () {
    setUp(() {
      // Clear cache before each test
      IconManager.clearIconCache();
    });

    tearDown(() {
      // Clear cache after each test
      IconManager.clearIconCache();
    });

    group('Icon Retrieval', () {
      test('should return BitmapDescriptor for valid car types', () {
        const carTypes = ['taxi', 'luxury', 'suv', 'mini', 'bike'];
        
        for (final carType in carTypes) {
          final icon = IconManager.getIcon(carType);
          expect(icon, isNotNull);
        }
      });

      test('should return fallback icon for invalid car types', () {
        const invalidCarTypes = ['invalid', 'unknown', '', 'nonexistent'];
        
        for (final carType in invalidCarTypes) {
          final icon = IconManager.getIcon(carType);
          expect(icon, isNotNull);
        }
      });

      test('should handle empty car type gracefully', () {
        expect(() => IconManager.getIcon(''), returnsNormally);
        final icon = IconManager.getIcon('');
        expect(icon, isNotNull);
      });

      test('should return consistent icons for same car type', () {
        const carType = 'taxi';
        
        final icon1 = IconManager.getIcon(carType);
        final icon2 = IconManager.getIcon(carType);
        
        // Should return the same cached instance
        expect(identical(icon1, icon2), isTrue);
      });
    });

    group('Icon Preloading', () {
      test('should preload icons without errors', () async {
        expect(() async => await IconManager.preloadIcons(), returnsNormally);
      });

      test('should preload icons with custom size', () async {
        expect(() async => await IconManager.preloadIcons(size: 64.0), returnsNormally);
      });

      test('should handle preloading with invalid size gracefully', () async {
        expect(() async => await IconManager.preloadIcons(size: -10.0), returnsNormally);
        expect(() async => await IconManager.preloadIcons(size: 0.0), returnsNormally);
      });

      test('should allow multiple preload calls', () async {
        await IconManager.preloadIcons();
        expect(() async => await IconManager.preloadIcons(), returnsNormally);
      });
    });

    group('Cache Management', () {
      test('should clear icon cache successfully', () {
        // Load some icons first
        IconManager.getIcon('taxi');
        IconManager.getIcon('luxury');
        
        // Clear cache should not throw
        expect(() => IconManager.clearIconCache(), returnsNormally);
      });

      test('should allow multiple cache clears', () {
        IconManager.clearIconCache();
        expect(() => IconManager.clearIconCache(), returnsNormally);
        expect(() => IconManager.clearIconCache(), returnsNormally);
      });

      test('should work correctly after cache clear', () {
        // Load icon, clear cache, load again
        final icon1 = IconManager.getIcon('taxi');
        IconManager.clearIconCache();
        final icon2 = IconManager.getIcon('taxi');
        
        expect(icon1, isNotNull);
        expect(icon2, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle asset loading failures gracefully', () {
        // Test with various edge cases that might cause asset loading issues
        const edgeCases = ['', ' ', '\n', '\t', 'very_long_car_type_name_that_does_not_exist'];
        
        for (final carType in edgeCases) {
          expect(() => IconManager.getIcon(carType), returnsNormally);
          final icon = IconManager.getIcon(carType);
          expect(icon, isNotNull);
        }
      });

      test('should provide fallback when assets are missing', () {
        // Even if assets are missing, should return a valid BitmapDescriptor
        final icon = IconManager.getIcon('definitely_missing_car_type');
        expect(icon, isNotNull);
      });

      test('should handle concurrent icon requests', () {
        const carType = 'taxi';
        final futures = <Future<void>>[];
        
        // Make multiple concurrent requests
        for (int i = 0; i < 10; i++) {
          futures.add(Future(() {
            final icon = IconManager.getIcon(carType);
            expect(icon, isNotNull);
          }));
        }
        
        expect(() async => await Future.wait(futures), returnsNormally);
      });
    });

    group('Performance', () {
      test('should cache icons for performance', () {
        const carType = 'luxury';
        
        // First call might be slower (loading)
        final stopwatch1 = Stopwatch()..start();
        final icon1 = IconManager.getIcon(carType);
        stopwatch1.stop();
        
        // Second call should be faster (cached)
        final stopwatch2 = Stopwatch()..start();
        final icon2 = IconManager.getIcon(carType);
        stopwatch2.stop();
        
        expect(icon1, isNotNull);
        expect(icon2, isNotNull);
        expect(identical(icon1, icon2), isTrue);
        
        // Second call should be significantly faster or at least not slower
        expect(stopwatch2.elapsedMicroseconds, lessThanOrEqualTo(stopwatch1.elapsedMicroseconds * 2));
      });

      test('should handle rapid successive calls efficiently', () {
        const carType = 'suv';
        const callCount = 100;
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < callCount; i++) {
          final icon = IconManager.getIcon(carType);
          expect(icon, isNotNull);
        }
        
        stopwatch.stop();
        
        // Should complete quickly (less than 100ms for 100 calls)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Integration', () {
      test('should work with all supported car types', () {
        const supportedTypes = ['taxi', 'luxury', 'suv', 'mini', 'bike'];
        
        for (final carType in supportedTypes) {
          final icon = IconManager.getIcon(carType);
          expect(icon, isNotNull);
          
          // Should be able to get the same icon multiple times
          final icon2 = IconManager.getIcon(carType);
          expect(identical(icon, icon2), isTrue);
        }
      });

      test('should maintain cache across different car types', () {
        final taxiIcon1 = IconManager.getIcon('taxi');
        final luxuryIcon1 = IconManager.getIcon('luxury');
        final taxiIcon2 = IconManager.getIcon('taxi');
        final luxuryIcon2 = IconManager.getIcon('luxury');
        
        // Same types should return identical cached instances
        expect(identical(taxiIcon1, taxiIcon2), isTrue);
        expect(identical(luxuryIcon1, luxuryIcon2), isTrue);
        
        // Different types should return different instances
        expect(identical(taxiIcon1, luxuryIcon1), isFalse);
      });
    });
  });
}