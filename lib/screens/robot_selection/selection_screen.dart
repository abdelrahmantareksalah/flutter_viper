import 'package:flutter/material.dart';
import 'package:flutter_viper/screens/robot_selection/robot_device.dart';
import 'package:flutter_viper/components/Ros2_connection/connection.dart';

class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({super.key});

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  // Our list of saved robots
  final List<RobotDevice> _myRobots = [
    RobotDevice(name: "Hureka", ip: "192.168.100.16", password: "123"),
  ];

  void _addRobot() {
    String name = "";
    String ip = "";
    String pass = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Robot"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: "Car Name"), onChanged: (v) => name = v),
            TextField(decoration: const InputDecoration(labelText: "IP Address"), onChanged: (v) => ip = v),
            TextField(decoration: const InputDecoration(labelText: "Password"), obscureText: true, onChanged: (v) => pass = v),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => _myRobots.add(RobotDevice(name: name, ip: ip, password: pass)));
              Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Select Your car")),
      floatingActionButton: FloatingActionButton(onPressed: _addRobot, child: const Icon(Icons.add)),
      body: ListView.builder(
        itemCount: _myRobots.length,
        itemBuilder: (context, index) {
          final robot = _myRobots[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.precision_manufacturing, color: Colors.blue),
              title: Text(robot.name),
              subtitle: Text("IP: ${robot.ip}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 1. Connect to ROS using this robot's IP
                rosConnection.connect(robot.ip);
                // 2. Go to Manual Control
                Navigator.pushNamed(context, '/manualControl');
              },
            ),
          );
        },
      ),
    );
  }
}