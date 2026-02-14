import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_viper/components/layout/LayoutComponent.dart';
import 'package:flutter_viper/components/loader/FutureLoaderComponent.dart';
import 'package:flutter_viper/components/maps/MapComponent.dart';
import 'package:flutter_viper/utils/map/getCurrentPosition.dart';
import 'package:flutter_viper/utils/map/getPreciseLocationStream.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class CreatePathScreen extends StatefulWidget {
  const CreatePathScreen({super.key});

  @override
  State<CreatePathScreen> createState() => _CreatePathScreenState();
}

class _CreatePathScreenState extends State<CreatePathScreen> {
  bool recording = false;
  MapController mapController = MapController();
  final random = Random();

  double latOffset = 0.0;
  double lngOffset = 0.0;

  StreamSubscription<Position>? locationStream;
  List<LatLng> recordedPath = [];

  @override
  void initState() {
    locationStream = getPreciseLocationStream().listen((Position position) {
      if (recording) {
        setState(() {
          var ll = LatLng(position.latitude + latOffset, position.longitude + lngOffset);
          recordedPath.add(ll);
          mapController.move(ll, 20.0);
          latOffset = random.nextDouble() * 0.0001;
          lngOffset = random.nextDouble() * 0.0001;
          print("New Location: ${position.latitude}, ${position.longitude}");
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    locationStream?.cancel();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutComponent(
      subTitle: 'Create Path',
      actions: [
        TextButton(
          onPressed: () => setState(() => recording = !recording),
          child: Text(recording ? 'End Recording' : 'Start Recording'),
        ),
      ],
      child: FutureLoaderComponent<Position?>(
        future: getCurrentPosition(),
        builder: (BuildContext context, Position? pos) {
          return MapComponent(
            mapController: mapController,
            initialPosition: LatLng(pos!.latitude, pos.longitude),
            polylineLayer: PolylineLayer(
              polylines: [
                Polyline(
                  points: recordedPath!,
                  color: Colors.blue,
                  useStrokeWidthInMeter: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
