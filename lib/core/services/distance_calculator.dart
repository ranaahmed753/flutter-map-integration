import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceCalculator {
  static final DistanceCalculator _instance = DistanceCalculator._();
  static DistanceCalculator get instance => _instance;

  double _liveDistance = 0.0;
  double get liveDistance => _liveDistance;

  DistanceCalculator._();

  double calculateDistance(LatLng start, LatLng end) {
    //Haversine formula to calculate distance
    const double earthRadius = 6371000; //meters

    double lat1 = start.latitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double dLat = (end.latitude - start.latitude) * pi / 180;
    double dLng = (end.longitude - start.longitude) * pi / 180;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  String get formattedDistance {
    if (_liveDistance < 1000) {
      return 'Rider is at customers door';
    } else {
      return '${(_liveDistance / 1000).toStringAsFixed(2)} km away';
    }
  }
}