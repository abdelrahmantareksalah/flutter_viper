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
  
  // Set your carlink distance parameter here (in meters)
  final double distanceThreshold = 2.0;

  @override
  void initState() {
    super.initState();

    locationStream = getPreciseLocationStream().listen((Position position) {
      if (recording) {
        var currentPoint = LatLng(position.latitude, position.longitude);

        // If the path is empty, drop the first point immediately
        if (recordedPath.isEmpty) {
          _recordAndPublish(currentPoint, position);
        } else {
          // Calculate distance between the last recorded point and current position
          double distanceInMeters = Geolocator.distanceBetween(
            recordedPath.last.latitude,
            recordedPath.last.longitude,
            currentPoint.latitude,
            currentPoint.longitude,
          );

          // Only record and publish if we moved past the threshold
          if (distanceInMeters >= distanceThreshold) {
            _recordAndPublish(currentPoint, position);
          }
        }
      }
    });
  }

  // Helper function to keep the logic clean
  void _recordAndPublish(LatLng point, Position position) {
    setState(() {
      recordedPath.add(point);
      mapController.move(point, 20.0);
      
      print("Recorded Point: ${position.latitude}, ${position.longitude}");

      // Send the live GPS point to ROS
      rosConnection.publishGPS(
        position.latitude, 
        position.longitude, 
        position.altitude
      );
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
          onPressed: () {
            setState(() {
              recording = !recording;
              // Optional: Clear the path if you start a fresh recording
              if (recording && recordedPath.isNotEmpty) {
                 recordedPath.clear();
              }
            });
          },
          child: Text(
            recording ? 'End Recording' : 'Start Recording',
            style: TextStyle(color: recording ? Colors.red : Colors.green),
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