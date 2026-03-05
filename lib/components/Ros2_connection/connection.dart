import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RosConnection {
  WebSocketChannel? _channel;
  bool isConnected = false; 

  void connect(String ipAddress, {Function()? onConnectionLost}) {
    disconnect(); 

    final url = 'ws://$ipAddress:9090'; 
    print("Attempting to connect to ROS at $url...");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // NEW: Tell the app we are connected immediately!
      isConnected = true; 

      // ADVERTISE THE TOPIC TO ROS 2
      final advertiseMsg = {
        "op": "advertise",
        "topic": "/cmd_vel",
        "type": "geometry_msgs/msg/Twist"
      };
      _channel?.sink.add(jsonEncode(advertiseMsg));
      // ==========================================

      _channel?.stream.listen(
        (message) {
          // (You can remove the isConnected = true from here if you want, 
          // since we already set it above!)
          final decodedMessage = jsonDecode(message);
        },
        onError: (error) {
          print("WebSocket Network Error: $error");
          isConnected = false;
          if (onConnectionLost != null) {
            onConnectionLost(); 
          }
        },
        onDone: () {
          print("WebSocket Disconnected Cleanly");
          isConnected = false;
          if (onConnectionLost != null) {
            onConnectionLost(); 
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("CRITICAL: Failed to initialize WebSocket: $e");
      isConnected = false;
      if (onConnectionLost != null) {
        onConnectionLost();
      }
    }
  }

  void publishCommand(double linearX, double angularZ) {
    print("Attempting to publish: $isConnected"); // ADD THIS LINE
    if (_channel == null || !isConnected) {
      print("BLOCKED: Channel is null or not connected"); // ADD THIS LINE
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
      _channel?.sink.add(jsonEncode(publishMsg));
    } catch (e) {
      print("Failed to send command. Connection lost: $e");
      isConnected = false;
    }
  }

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

final rosConnection = RosConnection();