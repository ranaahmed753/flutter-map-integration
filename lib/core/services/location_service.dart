import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  static LocationService get instance => LocationService._();
  final StreamController<Position> _positionController =
  StreamController<Position>.broadcast();
  Timer? _timer;

  Stream<Position> get stream => _positionController.stream;

  LocationService._();

  Future<Position?> getCurrentLocation() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    // Check and request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Please provide location permission and try again");
        await Geolocator.openAppSettings();
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Please provide location permission from settings and try again");
      await Geolocator.openAppSettings();
      return null;
    }

    // Get current location
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  Stream<Position> getPositionStream({int intervalSeconds = 5}) {
    _startPositionPolling(intervalSeconds);
    return _positionController.stream;
  }

  void _startPositionPolling(int intervalSeconds) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      final position = await getCurrentLocation();
      if (position != null && !_positionController.isClosed) {
        _positionController.add(position);
      }
    });
  }

  void _stopPositionPolling() {
    _timer?.cancel();
    _timer = null;
  }

  void disposePositionStream() {
    _stopPositionPolling();
    _positionController.close();
  }
}
