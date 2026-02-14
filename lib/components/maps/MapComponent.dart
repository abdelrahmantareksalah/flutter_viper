import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapComponent extends StatelessWidget {
  final LatLng initialPosition;
  final MarkerLayer markerLayer;
  final PolylineLayer polylineLayer;
  final MapController? mapController;
  
  const MapComponent({
    super.key,
    required this.initialPosition,
    this.markerLayer = const MarkerLayer(markers: []),
    this.polylineLayer = const PolylineLayer(polylines: []),
    this.mapController
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: initialPosition, initialZoom: 20.0),
      children: [
        // Tile Layer (the actual map imagery)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.viper.viper',
        ),
        markerLayer,
        polylineLayer,
        // Add attribution layer (required for many tile providers)
        // const AttributionWidget(
        //   attributionBuilder: (_) {
        //     return const Text(
        //       '© OpenStreetMap contributors',
        //       style: TextStyle(color: Colors.blue),
        //     );
        //   },
        // ),
      ],
    );
  }
}
