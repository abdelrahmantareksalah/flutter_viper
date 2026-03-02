import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RosConnection {
  WebSocketChannel? _channel;
  bool isConnected = false; // Tracks actual connection state

  // 1. Connect to the ROS car
  void connect(String ipAddress) {
    // Safety Net #1: Close any existing connection before starting a new one
    disconnect(); 

    final url = 'ws://$ipAddress:9090'; 
    print("Attempting to connect to ROS at $url...");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Listen for incoming messages from the car
      _channel?.stream.listen(
        (message) {
          isConnected = true; // We received data, connection is definitely alive
          final decodedMessage = jsonDecode(message);
          if (decodedMessage['op'] == 'publish' && decodedMessage['topic'] == '/chatter') {
            print('Received message from car: ${decodedMessage['msg']['data']}');
          }
        },
        onError: (error) {
          // Safety Net #2: If the network drops, catch it here instead of crashing
          print("WebSocket Network Error: $error");
          isConnected = false;
        },
        onDone: () {
          print("WebSocket Disconnected Cleanly");
          isConnected = false;
        },
        cancelOnError: true, // Stop listening if it throws a fatal error
      );
    } catch (e) {
      // Safety Net #3: Catch errors during the initial connection attempt
      print("CRITICAL: Failed to initialize WebSocket: $e");
      isConnected = false;
    }
  }

  // 2. Publish a command to the car (like FORWARD or LEFT)
  void publishCommand(double linearX, double angularZ) {
    // Safety Net #4: DO NOT send commands if the channel is null or dead
    if (_channel == null || !isConnected) {
      print("Ignored command: Robot is not connected.");
      return; 
    }

    final publishMsg = {
      "op": "publish",
      "topic": "/cmd_vel",
      "msg": {
        "linear": {"x": linearX, "y": 0.0, "z": 0.0},
        "angular": {"x": 0.0, "y": 0.0, "z": angularZ}
      }
    };
    
    try {
      // Safety Net #5: Catch errors if the socket closes exactly as we send data
      _channel?.sink.add(jsonEncode(publishMsg));
    } catch (e) {
      print("Failed to send command. Connection lost: $e");
      isConnected = false;
    }
  }

  // 3. Close the connection when done
  void disconnect() {
    try {
      if (_channel != null) {
        _channel?.sink.close();
        print("Disconnected from ROS");
      }
    } catch (e) {
      print("Error while disconnecting: $e");
    } finally {
      isConnected = false;
      _channel = null;
    }
  }
}

// Create a global instance of this connection so all screens can use it
final rosConnection = RosConnection();