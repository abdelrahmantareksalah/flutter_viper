import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_viper/components/layout/LayoutComponent.dart';
import 'package:flutter_viper/components/loader/FutureLoaderComponent.dart';
import 'package:flutter_viper/components/maps/MapComponent.dart';
import 'package:flutter_viper/utils/map/getCurrentPosition.dart';
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
  
  // Listen for the official path from the Pi
  StreamSubscription<List<LatLng>>? _pathSubscription;
  List<LatLng> recordedPath = [];

  @override
  void initState() {
    super.initState();

    // Listen to the Pi's EKF path stream!
    _pathSubscription = rosConnection.pathStream.listen((incomingPath) {
      setState(() {
        recordedPath = incomingPath;
        if (recordedPath.isNotEmpty) {
          // Center camera on the latest point the Pi saved
          mapController.move(recordedPath.last, 20.0);
        }
      });
    });
  }

  @override
  void dispose() {
    _pathSubscription?.cancel();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutComponent(
      subTitle: 'Create Path',
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              if (recording) {
                recording = false;
                rosConnection.sendSystemCommand("STOP_RECORD");
              } else {
                recording = true;
                recordedPath.clear(); // Clear the screen
                rosConnection.sendSystemCommand("START_RECORD");
              }
            });
          },
          child: Text(
            recording ? 'End Recording' : 'Start Recording',
            style: TextStyle(
              color: recording ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
      child: FutureLoaderComponent<Position?>(
        future: getCurrentPosition(),
        builder: (BuildContext context, Position? pos) {
          if (pos == null) return const Center(child: Text("Waiting for GPS..."));
          
          return MapComponent(
            mapController: mapController,
            initialPosition: LatLng(pos.latitude, pos.longitude),
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