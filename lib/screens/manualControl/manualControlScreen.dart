import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_viper/components/Ros2_connection/connection.dart';
import 'package:flutter_viper/components/buttons/HoldDetectorButton.dart';
import 'package:flutter_viper/components/loader/FutureLoaderComponent.dart';
import 'package:flutter_viper/components/maps/MapComponent.dart';
import 'package:flutter_viper/utils/map/getCurrentPosition.dart';
import 'package:flutter_viper/utils/map/getPreciseLocationStream.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  final double maxLinearSpeed = 1.0;
  final double maxAngularSpeed = 1.0;
  bool _isMapReady = false;
  MapController mapController = MapController();
  StreamSubscription<Position>? locationStream;

  double currentLinearValue = 0.0;
  double currentAngularValue = 0.0;

  void sendCommand() {
    rosConnection.publishCommand(currentLinearValue, currentAngularValue);
  }

  @override
  void initState() {
    locationStream = getPreciseLocationStream().listen((Position position) {
      if (_isMapReady) {
        setState(() {
          var ll = LatLng(position.latitude, position.longitude);
          mapController.move(ll, 20.0);
        });
      }
    });

    super.initState();

    if (!rosConnection.isConnected) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    locationStream?.cancel();
    mapController.dispose();
    rosConnection.publishCommand(0.0, 0.0);
    rosConnection.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hureka Manual Control"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapComponent(
              initialPosition: LatLng(0.0, 0.0),
              onMapReady: () => setState(() => _isMapReady = true),
              mapController: mapController,
              controllable: false,
            ),
          ), 

          Positioned(
            bottom: 100,
            left: 100,
            child: Joystick(
              listener: (details) {
                setState(() {
                  currentLinearValue = -(details.y);
                  currentAngularValue = -(details.x);
                  sendCommand();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
