import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/core/constants/image_path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:map/core/services/location_service.dart';

class RiderTrackingMapScreen extends StatefulWidget {
  const RiderTrackingMapScreen({super.key});

  @override
  State<RiderTrackingMapScreen> createState() => _RiderTrackingMapScreenState();
}

class _RiderTrackingMapScreenState extends State<RiderTrackingMapScreen> {
  List<LatLng> routePoints = [];

  PolylinePoints polylinePoints = PolylinePoints(
    apiKey: dotenv.env['API_KEY'] ?? '',
  );

  LatLng userLocation = LatLng(23.867308, 90.391591);
  LatLng riderLocation = LatLng(23.736987, 90.441165);

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  GoogleMapController? _mapController;

  int _riderIndex = 0;

  double _liveDistance = 0.0;

  bool _isLoading = true;

  BitmapDescriptor riderIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor userIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  _onMapCreated(GoogleMapController controller) => _mapController = controller;

  Future<void> _setupMap() async {
    await _loadCustomIcons();
    await _initializeMap();
  }

  Future<void> _loadCustomIcons() async {
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

  Future<void> _initializeMap() async {
    _createInitialMarkers();
    await _getRoute();
  }

  void _createInitialMarkers() {
    _liveDistance = _calculateDistance(userLocation, riderLocation);

    setState(() {
      _markers.addAll([
        Marker(
          markerId: const MarkerId('user'),
          position: userLocation,
          icon: userIcon,
          infoWindow: const InfoWindow(
            title: 'You',
            snippet: "More info about user",
          ),
        ),
        Marker(
          markerId: const MarkerId('rider'),
          position: riderLocation,
          icon: riderIcon,
          infoWindow: InfoWindow(title: 'Rider', snippet: formattedDistance),
        ),
      ]);
    });
  }

  Future<void> _getRoute() async {
    try {
      // Try to get real route from API
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(riderLocation.latitude, riderLocation.longitude),
          destination: PointLatLng(
            userLocation.latitude,
            userLocation.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        routePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        print("Route points loaded: ${routePoints.length}");
      } else {
        print("No route points found. Error: ${result.errorMessage}");
        print("Using mock route for testing...");

        // Create a mock route - interpolate points between user and rider
        routePoints = _generateMockRoute(riderLocation, userLocation);
        print("Mock route points generated: ${routePoints.length}");
      }

      setState(() {
        _buildPolyline();
        _isLoading = false;
      });

      // Start rider movement after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _startRiderMovement();
      });
    } catch (e) {
      print("Error getting route: $e");
      print("Using mock route for testing...");

      // Fallback to mock route
      routePoints = _generateMockRoute(riderLocation, userLocation);

      setState(() {
        _buildPolyline();
        _isLoading = false;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        _startRiderMovement();
      });
    }
  }

  List<LatLng> _generateMockRoute(LatLng start, LatLng end) {
    List<LatLng> points = [];
    int numberOfPoints = 30; // Number of intermediate points

    for (int i = 0; i <= numberOfPoints; i++) {
      double ratio = i / numberOfPoints;

      // Linear interpolation with slight curve for realism
      double lat = start.latitude + (end.latitude - start.latitude) * ratio;
      double lng = start.longitude + (end.longitude - start.longitude) * ratio;

      // Add slight curve variation
      double offset = sin(ratio * pi) * 0.002;
      lng += offset;

      points.add(LatLng(lat, lng));
    }

    return points;
  }

  void _buildPolyline() {
    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 10,
        points: routePoints,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  void _startRiderMovement() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_riderIndex >= routePoints.length) {
        timer.cancel();
        return;
      }

      setState(() {
        riderLocation = routePoints[_riderIndex];
        _liveDistance = _calculateDistance(userLocation, riderLocation);

        _markers.removeWhere((m) => m.markerId.value == 'rider');
        _markers.add(
          Marker(
            markerId: const MarkerId('rider'),
            position: riderLocation,
            icon: riderIcon ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: 'Rider', snippet: formattedDistance),
          ),
        );
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(riderLocation));

      _riderIndex++;
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
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

  navigateToCurrentLocation() async {
    Position? position = await LocationService.instance.getCurrentLocation();
    if (position == null) {
      return;
    }

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("My location marker"),
        position: LatLng(position.latitude, position.longitude),
        icon: currentLocationIcon,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: CameraPosition(
              target: userLocation,
              zoom: 14,
            ),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            polylines: _polylines,
            markers: _markers,
            zoomControlsEnabled: true,
            onMapCreated: _onMapCreated,
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '$formattedDistance',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, size: 30),
        onPressed: navigateToCurrentLocation,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
