import 'package:flutter/material.dart';
import 'package:flutter_viper/screens/robot_selection/robot_device.dart';
import 'package:flutter_viper/components/Ros2_connection/connection.dart';

class CommandScreen extends StatefulWidget {
  const CommandScreen({super.key});

  @override
  State<CommandScreen> createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  // Your list of saved robots
  final List<RobotDevice> _myRobots = [
    RobotDevice(name: "hureka", ip: "172.20.248.110", password: "123"),
  ];

  // --- 1. UNLOCK LOGIC ---
  void _checkPasswordAndNavigate(RobotDevice robot) {
    String inputPass = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Access ${robot.name}"),
        // THE FIX: Wrapped the TextField in a SingleChildScrollView
        content: SingleChildScrollView(
          child: TextField(
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Enter Password",
              prefixIcon: Icon(Icons.vpn_key),
            ),
            onChanged: (v) => inputPass = v,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () {
              if (inputPass == robot.password) {
                Navigator.pop(context); // Close dialog
                rosConnection.connect(robot.ip); // Connect to the car
                Navigator.pushNamed(context, '/manualControl'); // Go to Joystick
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Access Denied: Wrong Password"), 
                    backgroundColor: Colors.red
                  ),
                );
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  // --- 2. ADD ROBOT LOGIC ---
  void _addNewRobot() {
    String name = "";
    String ip = "";
    String pass = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Register New VIPER"),
        // THE FIX: Wrapped the entire Column in a SingleChildScrollView
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tells the column to take minimum height
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Car Name"), 
                onChanged: (v) => name = v
              ),
              TextField(
                decoration: const InputDecoration(labelText: "IP Address"), 
                onChanged: (v) => ip = v
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Set Password"), 
                obscureText: true, 
                onChanged: (v) => pass = v
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty && ip.isNotEmpty) {
                setState(() => _myRobots.add(RobotDevice(name: name, ip: ip, password: pass)));
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensures the whole screen background adjusts when the keyboard pops up
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: const Text("Robot List"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRobot,
        child: const Icon(Icons.add_to_queue),
      ),
      // --- RESPONSIVE LAYOUT BUILDER ---
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine how many columns to show based on screen width
          int columns = 1;
          if (constraints.maxWidth > 900) {
            columns = 3; // Desktop/Large Tablet Landscape
          } else if (constraints.maxWidth > 600) {
            columns = 2; // Tablet Portrait
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 90, // Fixes the height of the card
            ),
            itemCount: _myRobots.length,
            itemBuilder: (context, index) {
              final robot = _myRobots[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: ListTile(
                    leading: const Icon(Icons.settings_remote, color: Colors.blue, size: 36),
                    title: Text(robot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("IP: ${robot.ip}"),
                    trailing: const Icon(Icons.lock_outline),
                    onTap: () => _checkPasswordAndNavigate(robot),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}