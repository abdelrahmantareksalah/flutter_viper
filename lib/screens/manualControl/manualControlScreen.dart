import 'dart:async';
import 'package:flutter/material.dart';

// 1. We import the connection class we just built!
import 'package:flutter_viper/components/Ros2_connection/connection.dart';

// (Keep your other map and GPS imports here)

class ManualControlScreen extends StatefulWidget {
  // I fixed the "super parameter" warning here!
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  Timer? _movementTimer;

  // 2. INIT STATE: Runs automatically when this screen opens
  @override
  void initState() {
    super.initState();
    // Connect to your ROS car the moment this controller screen opens!
    // TODO: Replace '192.168.1.X' with your car's actual local Wi-Fi IP address
    rosConnection.connect('192.168.100.1'); 
  }

  // 3. DISPOSE: Runs automatically when you navigate away from this screen
  @override
  void dispose() {
    // Safety first: stop the car and kill the timer if we close the app/screen!
    _movementTimer?.cancel();
    rosConnection.publishCommand(0 , 0);
    rosConnection.disconnect(); 
    super.dispose();
  }

  // 4. Send the command using the WebSocket instead of just printing it
 // 4. Send velocity values (Linear for speed, Angular for turning)
  void sendCommand(double linear, double angular) {
    rosConnection.publishCommand(linear, angular);
  }

  void _startMoving(double linear, double angular) {
    _movementTimer?.cancel(); 
    sendCommand(linear, angular); 
    _movementTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      sendCommand(linear, angular);
    });
  }

  void _brakes() {
    _movementTimer?.cancel(); 
    sendCommand(0.0 , 0.0); // 0.0 means stop!    
  }

  void _stopSignal(){
    _movementTimer?.cancel();
    sendCommand(0.0 , 0.0);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hureka Manual Control"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                "GPS Map goes here later!",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          
          // --- THE D-PAD CONTROLS ---
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: [
                
                // FORWARD BUTTON
                Listener(
                  onPointerDown: (_) => _startMoving(0.5 , 0.0),
                  onPointerUp: (_) => _stopSignal(),
                  onPointerCancel: (_) => _stopSignal(),
                  child: ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                    child: const Icon(Icons.arrow_upward, size: 40),
                  ),
                ),
                const SizedBox(height: 10),
                
                // LEFT, BRAKE, RIGHT BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LEFT BUTTON
                    Listener(
                      onPointerDown: (_) => _startMoving(0.0 , 1.0),
                      onPointerUp: (_) => _stopSignal(),
                      onPointerCancel: (_) => _stopSignal(),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                        child: const Icon(Icons.arrow_back, size: 40),
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // E-BRAKE (Still just a single tap to stop)
                    ElevatedButton(
                      onPressed: () {
                        _movementTimer?.cancel();
                        _brakes();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.red, // Red for danger!
                      ),
                      child: const Icon(Icons.stop, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    
                    // RIGHT BUTTON
                    Listener(
                      onPointerDown: (_) => _startMoving(0.0 , -1.0),
                      onPointerUp: (_) => _stopSignal(),
                      onPointerCancel: (_) => _stopSignal(),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                        child: const Icon(Icons.arrow_forward, size: 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // REVERSE BUTTON
                Listener(
                  onPointerDown: (_) => _startMoving(-0.5, 0.0),
                  onPointerUp: (_) => _stopSignal(),
                  onPointerCancel: (_) => _stopSignal(),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                    child: const Icon(Icons.arrow_downward, size: 40),
                  ),
                ),
              ],
            ),
          ),
        ], // -> THIS closes the main body Column
      ), // -> THIS closes the Scaffold body
    ); // -> THIS closes the Scaffold
  } // -> THIS closes the build method
} // -> THIS closes the State class
