import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_viper/components/Ros2_connection/connection.dart';

class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  final double maxLinearSpeed = 1.0;
  final double maxAngularSpeed = 1.0;

 @override
  void initState() {
    super.initState();
    // We REMOVED rosConnection.connect() from here because the 
    // DeviceSelectionScreen already did it!
    
    // Optional: We can still add a safety check just in case the connection drops
    // while we are driving.
    if (!rosConnection.isConnected) {
       Navigator.pop(context); // Kick back to selection screen if dead
    }
  }

  @override
  void dispose() {
    rosConnection.publishCommand(0.0, 0.0);
    rosConnection.disconnect();
    super.dispose();
  }

  void _onJoystickMoved(StickDragDetails details) {
    double linearX = -(details.y);
    double angularZ = -(details.x);

    print("Joystick Output -> Linear: $linearX, Angular: $angularZ");
    rosConnection.publishCommand(linearX, angularZ);
  }

  void _brakes() {
    rosConnection.publishCommand(0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hureka Manual Control"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
          child: Column(
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
              
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Column(
                  children: [
                    Joystick(
                      listener: (details) {
                        _onJoystickMoved(details);
                      },
                    ),
                    const SizedBox(height: 30),
                    
                    // --- EMERGENCY STOP BUTTON ---
                    ElevatedButton(
                      onPressed: _brakes,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "EMERGENCY STOP",
                        style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // --- DEBUG TEST BUTTON ---
                    ElevatedButton(
                      onPressed: () {
                        print("TEST BUTTON PRESSED - SENDING FORWARD COMMAND");
                        rosConnection.publishCommand(1.0, 0.0);
                      },
                      child: const Text("FORCED FORWARD TEST"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}