import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_viper/components/Ros2_connection/connection.dart'; // Adjust path if needed

class ConnectionListScreen extends StatefulWidget {
  const ConnectionListScreen({super.key});

  @override
  State<ConnectionListScreen> createState() => _ConnectionListScreenState();
}

class _ConnectionListScreenState extends State<ConnectionListScreen> {
  List<String> _savedRobots = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRobots();
  }

  // Load the list from the phone's memory
  Future<void> _loadSavedRobots() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // We save them as "Name|IP" strings (e.g., "Viper Buggy|192.168.1.50")
      _savedRobots = prefs.getStringList('saved_robots') ?? [];
    });
  }

  // Save the list back to the phone
  Future<void> _saveRobots() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_robots', _savedRobots);
  }

  // Show a popup to add a new robot
  void _showAddRobotDialog() {
    final nameController = TextEditingController();
    final ipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Robot"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Robot Name (e.g. Pi Hotspot)"),
            ),
            TextField(
              controller: ipController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "IP Address (e.g. 192.168.43.50)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && ipController.text.isNotEmpty) {
                setState(() {
                  _savedRobots.add("${nameController.text}|${ipController.text}");
                });
                _saveRobots();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Connect and jump to the Home Screen
  void _connectToRobot(String ip) {
    rosConnection.connect(ip);
    Navigator.pushReplacementNamed(context, '/home');
  }

  // Delete a saved robot
  void _deleteRobot(int index) {
    setState(() {
      _savedRobots.removeAt(index);
    });
    _saveRobots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Connections"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _savedRobots.isEmpty
          ? const Center(
              child: Text(
                "No robots saved yet.\nTap the + button to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _savedRobots.length,
              itemBuilder: (context, index) {
                // Split the string back into Name and IP
                final parts = _savedRobots[index].split('|');
                final name = parts[0];
                final ip = parts.length > 1 ? parts[1] : "Unknown IP";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.smart_toy, color: Colors.blue, size: 36),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(ip),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteRobot(index),
                    ),
                    onTap: () => _connectToRobot(ip), // Tap the card to connect!
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRobotDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Robot"),
      ),
    );
  }
}