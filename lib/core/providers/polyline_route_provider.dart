import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineRouteProvider extends ChangeNotifier {
  Set<Marker> markers = {};
  Set<Polyline> polyline = {};
  Set<Polygon> polygon = {};
  LatLng currentLocation = LatLng(23.784178, 90.431136);
  List<LatLng> pointsOnMap = [
    LatLng(23.798827, 90.438391),
    LatLng(23.777073, 90.362502),
    LatLng(23.857673, 90.353813),
    LatLng(23.837953, 90.263194),
    LatLng(23.785369, 90.429949),
  ];
  GoogleMapController? mapController;

  init() {
    initMarkers();
    initPolyline();
    initPolygon();
    notifyListeners();
  }

  initMarkers() {
    markers.clear();
    markers = pointsOnMap
        .asMap()
        .entries
        .map(
          (point) => Marker(
            markerId: MarkerId("marker_id_${point.key}"),
            position: point.value,
          ),
        )
        .toSet();
  }

  initPolyline() {
    polyline = {
      Polyline(
        polylineId: PolylineId("polyline_id}"),
        points: pointsOnMap,
        width: 10,
        color: Colors.blue,
      ),
    };
  }

  initPolygon() {
    polygon.add(
      Polygon(
        polygonId: PolygonId("polygon_id"),
        points: pointsOnMap,
        strokeColor: Colors.blueAccent,
        strokeWidth: 4,
        fillColor: Colors.green.withOpacity(0.4),
        geodesic: true,
      ),
    );
  }

  onMapCreated(GoogleMapController controller) => mapController = controller;
}
