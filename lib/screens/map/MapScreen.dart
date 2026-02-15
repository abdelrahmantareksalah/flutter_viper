import 'package:flutter/material.dart';
import 'package:flutter_viper/components/layout/LayoutComponent.dart';
import 'package:flutter_viper/components/loader/FutureLoaderComponent.dart';
import 'package:flutter_viper/components/maps/MapComponent.dart';
import 'package:flutter_viper/utils/map/getCurrentPosition.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override

  Widget build(BuildContext context) {
    return LayoutComponent(
      subTitle: 'Map',
      child: FutureLoaderComponent<Position?>(
        future: getCurrentPosition(),
        builder: (BuildContext context, Position? pos) {
          return MapComponent(
            initialPosition: LatLng(pos!.latitude, pos.longitude),
          );
        },
      ),
    );
  }
}
