import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_viper/components/layout/LayoutComponent.dart';
import 'package:flutter_viper/components/loader/FutureLoaderComponent.dart';
import 'package:flutter_viper/components/maps/MapComponent.dart';
import 'package:flutter_viper/utils/map/getCurrentPosition.dart';
import 'package:flutter_viper/utils/map/getPreciseLocationStream.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// Import your universal ROS connection
import 'package:flutter_viper/components/Ros2_connection/connection.dart'; 

class CreatePathScreen extends StatefulWidget {
  const CreatePathScreen({super.key});

  @override
  State<CreatePathScreen> createState() => _CreatePathScreenState();
}

class _CreatePathScreenState extends State<CreatePathScreen> {
  bool recording = false;
  MapController mapController = MapController();
  
  StreamSubscription<Position>? locationStream;
  List<LatLng> recordedPath = [];

  @override
  void initState() {
    super.initState();

    locationStream = getPreciseLocationStream().listen((Position position) {
      if (recording) {
        setState(() {
          var ll = LatLng(position.latitude, position.longitude);
          recordedPath.add(ll);
          mapController.move(ll, 20.0);
          
          print("Recorded Point: ${position.latitude}, ${position.longitude}");

          // Send the live GPS point to ROS using your global connection!
          rosConnection.publishGPS(
            position.latitude, 
            position.longitude, 
            position.altitude
          );
        });
      }
    });
  }

  @override
  void dispose() {
    locationStream?.cancel();
    mapController.dispose();
    // We DO NOT close the rosConnection here, so the rest of the app stays connected!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutComponent(
      subTitle: 'Create Path',
      actions: [
        TextButton(
          onPressed: () => setState(() => recording = !recording),
          child: Text(
            recording ? 'End Recording' : 'Start Recording',
            style: TextStyle(color: recording ? Colors.red : Colors.green),
          ),
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
                  points: recordedPath,
                  color: Colors.blue,
                  strokeWidth: 4.0, 
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}