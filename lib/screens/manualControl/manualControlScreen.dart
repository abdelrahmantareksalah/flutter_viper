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

  double currentLinearValue = 0.0;
  double currentAngularValue = 0.0;

  void sendCommand() {
    rosConnection.publishCommand(currentLinearValue, currentAngularValue);
  }

  @override
  void initState() {
    super.initState();

    if (!rosConnection.isConnected) {
      // Defer the pop to ensure it doesn't conflict with the initial build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
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
      // Using a plain background instead of the map
      backgroundColor: Colors.grey[100], 
      body: Stack(
        children: [
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