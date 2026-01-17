import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/image_path.dart';
import 'distance_calculator.dart';
import 'location_service.dart';

class MapService extends ChangeNotifier {
  // 🔥 Singleton
  static final MapService instance = MapService._();

  MapService._();

  // 🗺 Map Controller
  GoogleMapController? mapController;

  // 📍 Icons
  BitmapDescriptor riderIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor userIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  // 📍 Locations
  LatLng userLocation = const LatLng(23.867308, 90.391591);
  LatLng riderLocation = const LatLng(23.736987, 90.441165);

  // 🧭 Route & Map Data
  List<LatLng> routePoints = [];
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};

  // 📏 Distance
  double liveDistance = 0.0;

  // ⏳ State
  bool isLoading = true;
  int _riderIndex = 0;
  Timer? _movementTimer;

  // 🧵 Polyline Service
  final PolylinePoints polylinePoints = PolylinePoints(
    apiKey: dotenv.env['API_KEY'] ?? '',
  );

  // 🚀 PUBLIC SETUP
  Future<void> setupMap() async {
    await loadCustomIcons();
    await _initializeMap();
  }

  onMapCreated(GoogleMapController controller) => mapController = controller;

  // 🎨 Load Icons
  Future<void> loadCustomIcons() async {
    riderIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      ImagePath.riderIcon,
    );
    userIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      ImagePath.userIcon,
    );
    currentLocationIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      ImagePath.currentLocationIcon,
    );
  }

  // 🧠 Initialize
  Future<void> _initializeMap() async {
    _createInitialMarkers();
    await _getRoute();
  }

  // 📍 Initial Markers
  void _createInitialMarkers() {
    liveDistance = DistanceCalculator.instance.calculateDistance(
      userLocation,
      riderLocation,
    );

    markers.clear();
    markers.addAll([
      Marker(
        markerId: const MarkerId('user'),
        position: userLocation,
        icon: userIcon,
        infoWindow: const InfoWindow(title: 'You'),
      ),
      Marker(
        markerId: const MarkerId('rider'),
        position: riderLocation,
        icon: riderIcon,
        infoWindow: InfoWindow(
          title: 'Rider',
          snippet: DistanceCalculator.instance.formattedDistance,
        ),
      ),
    ]);

    notifyListeners();
  }

  // 🛣 Route Fetch
  Future<void> _getRoute() async {
    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(riderLocation.latitude, riderLocation.longitude),
          destination: PointLatLng(
            userLocation.latitude,
            userLocation.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      routePoints = result.points.isNotEmpty
          ? result.points.map((p) => LatLng(p.latitude, p.longitude)).toList()
          : _generateMockRoute(riderLocation, userLocation);

      _buildPolyline();
      isLoading = false;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), _startRiderMovement);
    } catch (_) {
      routePoints = _generateMockRoute(riderLocation, userLocation);
      _buildPolyline();
      isLoading = false;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), _startRiderMovement);
    }
  }

  // ➖ Polyline
  void _buildPolyline() {
    polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 8,
        points: routePoints,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
    notifyListeners();
  }

  // 🧪 Mock Route
  List<LatLng> _generateMockRoute(LatLng start, LatLng end) {
    const int count = 100;
    List<LatLng> points = [];

    for (int i = 0; i <= count; i++) {
      double t = i / count;
      double lat = start.latitude + (end.latitude - start.latitude) * t;
      double lng = start.longitude + (end.longitude - start.longitude) * t;
      lng += sin(t * pi) * 0.002;
      points.add(LatLng(lat, lng));
    }
    return points;
  }

  // 🏍 Rider Movement
  void _startRiderMovement() {
    _movementTimer?.cancel();
    _riderIndex = 0;

    _movementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_riderIndex >= routePoints.length) {
        timer.cancel();
        return;
      }

      riderLocation = routePoints[_riderIndex];
      _riderIndex++;
      print(riderLocation);
      print(_riderIndex);

      liveDistance = DistanceCalculator.instance.calculateDistance(
        riderLocation,
        userLocation,
      );

      _updateRiderMarker();
      _updateCamera(); // 🔥 FIX: Move camera with rider
    });
  }

  // 🔄 Update Rider Marker
  void _updateRiderMarker() {
    //markers.removeWhere((m) => m.markerId.value == 'rider');

    markers.add(
      Marker(
        markerId: const MarkerId('rider'),
        position: riderLocation,
        icon: riderIcon,
        infoWindow: InfoWindow(
          title: 'Rider',
          snippet: DistanceCalculator.instance.formattedDistance,
        ),
      ),
    );

    notifyListeners();
  }

  // 🎥 Update Camera to Follow Rider
  void _updateCamera() {
    if (mapController == null) return;

    // Calculate bounds to show both rider and user
    double minLat = min(riderLocation.latitude, userLocation.latitude);
    double maxLat = max(riderLocation.latitude, userLocation.latitude);
    double minLng = min(riderLocation.longitude, userLocation.longitude);
    double maxLng = max(riderLocation.longitude, userLocation.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100), // 100px padding
    );
  }

  // 🎯 Current Location
  Future<void> navigateToCurrentLocation() async {
    Position? position = await LocationService.instance.getCurrentLocation();
    if (position == null) return;

    final LatLng current = LatLng(position.latitude, position.longitude);

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(current, 15));

    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: current,
        icon: currentLocationIcon,
      ),
    );

    notifyListeners();
  }

  // 🧹 Cleanup
  void disposeService() {
    _movementTimer?.cancel();
  }
}
