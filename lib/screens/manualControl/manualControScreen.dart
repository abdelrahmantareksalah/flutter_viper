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
import 'package:flutter/material.dart';

// (Keep your other imports here for the map and GPS later)

// 1. We fixed the naming so it matches perfectly
class ManualControlScreen extends StatefulWidget {
  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

// 2. This is the "State" - where the screen actually gets built and updated
class _ManualControlScreenState extends State<ManualControlScreen> {
  
  // A simple function to test our buttons before we add the server connection
  void sendCommand(String command) {
    print("Sending command to buggy: $command");
    // Later, the WebSocket code goes here!
  }

  // 3. The 'build' method is the actual UI you see on the phone
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ILIOS Manual Control"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Pushes controls to the bottom
        children: [
          // This empty space is where your MapComponent will go later!
          Expanded(
            child: Center(
              child: Text("GPS Map goes here later!", style: TextStyle(color: Colors.grey)),
            ),
          ),
          
          // --- THE D-PAD CONTROLS ---
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: [
                // FORWARD BUTTON
                ElevatedButton(
                  onPressed: () => sendCommand("FORWARD"),
                  child: Icon(Icons.arrow_upward, size: 40),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(20)),
                ),
                SizedBox(height: 10),
                
                // LEFT, BRAKE, RIGHT BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => sendCommand("LEFT"),
                      child: Icon(Icons.arrow_back, size: 40),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.all(20)),
                    ),
                    SizedBox(width: 10),
                    
                    // E-BRAKE
                    ElevatedButton(
                      onPressed: () => sendCommand("BRAKE"),
                      child: Icon(Icons.stop, size: 40, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(20),
                        backgroundColor: Colors.red, // Red for danger!
                      ),
                    ),
                    SizedBox(width: 10),
                    
                    ElevatedButton(
                      onPressed: () => sendCommand("RIGHT"),
                      child: Icon(Icons.arrow_forward, size: 40),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.all(20)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                
                // REVERSE BUTTON
                ElevatedButton(
                  onPressed: () => sendCommand("REVERSE"),
                  child: Icon(Icons.arrow_downward, size: 40),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}