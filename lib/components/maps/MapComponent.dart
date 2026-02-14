import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapComponent extends StatelessWidget {
  const MapComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(51.509364, -0.128928),  
           initialZoom: 20.0,  
         ),
        children: [
          // Tile Layer (the actual map imagery)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.viper.viper',  
          ),
          // Example of adding a marker
          MarkerLayer(
            markers: [
            
            ],
          ),
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