
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/core/services/distance_calculator.dart';
import 'package:map/core/services/map_service.dart';
import 'package:provider/provider.dart';
class RiderTrackingMapScreen extends StatelessWidget {
  const RiderTrackingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mapService = context.read<MapService>();
    return Scaffold(
      body: Consumer<MapService>(builder: (_,ms,_){
        return Stack(
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(
                target: ms.userLocation,
                zoom: 14,
              ),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              polylines: ms.polylines,
              markers: ms.markers,
              zoomControlsEnabled: true,
              onMapCreated: ms.onMapCreated,
            ),
            if (ms.isLoading)
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
                    DistanceCalculator.instance.formattedDistance,
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
        );
      }),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, size: 30),
        onPressed: mapService.navigateToCurrentLocation,
      ),
    );
  }
}

