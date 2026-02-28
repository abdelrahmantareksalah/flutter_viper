import 'dart:async';
import 'package:flutter/material.dart';

// (Keep your other map and GPS imports here)

class ManualControlScreen extends StatefulWidget {
  // I fixed the "super parameter" warning here!
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  Timer? _movementTimer;

  void sendCommand(String command) {
    print("Sending command to buggy: $command");
    // Later, the WebSocket code goes here!
  }

  void _startMoving(String command) {
    _movementTimer?.cancel(); 
    sendCommand(command); 
    _movementTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      sendCommand(command);
    });
  }

  void _stopMoving() {
    _movementTimer?.cancel(); 
    sendCommand("BRAKE");     
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
                  onPointerDown: (_) => _startMoving("FORWARD"),
                  onPointerUp: (_) => _stopMoving(),
                  onPointerCancel: (_) => _stopMoving(),
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
                      onPointerDown: (_) => _startMoving("LEFT"),
                      onPointerUp: (_) => _stopMoving(),
                      onPointerCancel: (_) => _stopMoving(),
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
                        sendCommand("BRAKE");
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
                      onPointerDown: (_) => _startMoving("RIGHT"),
                      onPointerUp: (_) => _stopMoving(),
                      onPointerCancel: (_) => _stopMoving(),
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
                  onPointerDown: (_) => _startMoving("REVERSE"),
                  onPointerUp: (_) => _stopMoving(),
                  onPointerCancel: (_) => _stopMoving(),
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