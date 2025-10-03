import 'package:flutter_test/flutter_test.dart';
import 'package:animated_car_marker/animated_car_marker.dart';

void main() {
  test('package exports are accessible', () {
    // Test that main exports are accessible
    expect(AnimatedCarMarkerManager, isNotNull);
    expect(RotationTarget.values, isNotEmpty);
    expect(RotationTarget.values.length, equals(4));
  });
}
