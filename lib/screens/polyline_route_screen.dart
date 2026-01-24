import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/core/providers/polyline_route_provider.dart';
import 'package:provider/provider.dart';

class PolylineRouteScreen extends StatelessWidget {
  const PolylineRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Consumer<PolylineRouteProvider>(
            builder: (_, provider, _) {
              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: provider.currentLocation,
                  zoom: 14,
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                polygons: provider.polygon,
                polylines: provider.polyline,
                markers: provider.markers,
                zoomControlsEnabled: true,
                onMapCreated: provider.onMapCreated,
              );
            },
          ),
        ],
      ),
    );
  }
}
