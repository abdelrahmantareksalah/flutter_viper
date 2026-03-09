import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_viper/components/Ros2_connection/connection.dart'; 
import 'package:flutter_viper/utils/map/getCurrentPosition.dart';
import 'package:flutter_viper/components/loader/FutureLoaderComponent.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  
  LatLng? _targetLocation;
  List<LatLng> _calculatedPath = []; 
  bool _isConfirming = false; 
  StreamSubscription<List<LatLng>>? _pathSubscription;

  @override
  void initState() {
    super.initState();
    // Tune into the ROS 2 radio station! 
    // Whenever the buggy calculates a path, it broadcasts here and updates the map instantly.
    _pathSubscription = rosConnection.pathStream.listen((newPath) {
      setState(() {
        _calculatedPath = newPath;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Route received from VIPER!"), 
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pathSubscription?.cancel(); // Turn off the radio when we leave the screen
    super.dispose();
  }

  // When the user taps the map
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _targetLocation = point;
      _calculatedPath = []; // Clear the old route
      _isConfirming = true; // Pop up the confirm button!
    });
  }

  // When the user clicks "Confirm"
  void _confirmDestination() {
    setState(() {
      _isConfirming = false; // Hide the button
    });
    
    // Send the exact GPS coordinates to the ROS 2 computer!
    rosConnection.publishGoalGPS(
      _targetLocation!.latitude, 
      _targetLocation!.longitude
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Calculating route..."), 
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VIPER Navigation"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: FutureLoaderComponent<Position?>(
        future: getCurrentPosition(),
        builder: (BuildContext context, Position? pos) {
          if (pos == null) {
            return const Center(child: CircularProgressIndicator());
          }

          LatLng currentLocation = LatLng(pos.latitude, pos.longitude);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLocation,
                  initialZoom: 18.0,
                  onTap: _onMapTap, 
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_viper',
                  ),
                  
                  // Draws the path from ROS
                  PolylineLayer(
                    polylines: [
                      if (_calculatedPath.isNotEmpty)
                        Polyline(
                          points: _calculatedPath,
                          color: Colors.blueAccent,
                          strokeWidth: 5.0,
                        ),
                    ],
                  ),

                  // Draws your location and the target pin
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.circle , color: Colors.green, size: 40),
                      ),
                      if (_targetLocation != null)
                        Marker(
                          point: _targetLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                    ],
                  ),
                ],
              ),

              // The floating Confirm Button
              if (_isConfirming)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    icon: const Icon(Icons.check_circle, size: 28),
                    label: const Text(
                      "Confirm Destination",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _confirmDestination,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[900],
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () async {
          Position? pos = await getCurrentPosition();
          if (pos != null) {
            _mapController.move(LatLng(pos.latitude, pos.longitude), 18.0);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}