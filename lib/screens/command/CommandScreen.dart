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
    RobotDevice(name: "hureka", ip: "192.168.100.16", password: "123"),
  ];

  // --- 1. UNLOCK LOGIC ---
  void _checkPasswordAndNavigate(RobotDevice robot) {
    String inputPass = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Access ${robot.name}"),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Enter Password",
            prefixIcon: Icon(Icons.vpn_key),
          ),
          onChanged: (v) => inputPass = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (inputPass == robot.password) {
                Navigator.pop(context); // Close dialog
                rosConnection.connect(robot.ip); // Connect to the car
                Navigator.pushNamed(context, '/manualControl'); // Go to Joystick
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Access Denied: Wrong Password"), backgroundColor: Colors.red),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: "Car Name"), onChanged: (v) => name = v),
            TextField(decoration: const InputDecoration(labelText: "IP Address"), onChanged: (v) => ip = v),
            TextField(decoration: const InputDecoration(labelText: "Set Password"), obscureText: true, onChanged: (v) => pass = v),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
      appBar: AppBar(
        title: const Text("VIPER COMMAND"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRobot,
        child: const Icon(Icons.add_to_queue),
      ),
      body: ListView.builder(
        itemCount: _myRobots.length,
        itemBuilder: (context, index) {
          final robot = _myRobots[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ListTile(
              leading: const Icon(Icons.settings_remote, color: Colors.blue),
              title: Text(robot.name),
              subtitle: Text("IP: ${robot.ip}"),
              trailing: const Icon(Icons.lock_open),
              onTap: () => _checkPasswordAndNavigate(robot),
            ),
          );
        },
      ),
    );
  }
}