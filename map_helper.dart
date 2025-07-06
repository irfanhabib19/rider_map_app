import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelper {
  static List<LatLng> generateNearbyLocations(LatLng origin, int count) {
    final List<LatLng> locations = [];
    final random = Random();
    const radiusInKm = 5.0;

    for (int i = 0; i < count; i++) {
      final latOffset = (random.nextDouble() - 0.5) * (radiusInKm / 110.574);
      final lngOffset = (random.nextDouble() - 0.5) *
          (radiusInKm / (111.320 * cos(origin.latitude * pi / 180)));
      locations.add(
        LatLng(origin.latitude + latOffset, origin.longitude + lngOffset),
      );
    }

    return locations;
  }
}
