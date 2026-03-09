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
      
      isConnected = true; 

      // 1. ADVERTISE THE JOYSTICK TOPIC
      final advertiseMsg = {
        "op": "advertise",
        "topic": "/cmd_vel",
        "type": "geometry_msgs/msg/Twist"
      };
      _channel?.sink.add(jsonEncode(advertiseMsg));
      
      // 2. NEW: ADVERTISE THE COORDINATE TOPIC
      final advertisePointMsg = {
        "op": "advertise",
        "topic": "/target_xy",
        "type": "geometry_msgs/msg/Point"
      };
      _channel?.sink.add(jsonEncode(advertisePointMsg));
      // ==========================================

      _channel?.stream.listen(
        (message) {
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
    // 3. ADVERTISE THE GPS TOPIC
    final advertiseGpsMsg = {
      "op": "advertise",
      "topic": "/gps/fix",
      "type": "sensor_msgs/msg/NavSatFix"
    };
    _channel?.sink.add(jsonEncode(advertiseGpsMsg)
    );
  }

  // Your existing joystick function
  void publishCommand(double linearX, double angularZ) {
    if (_channel == null || !isConnected) {
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

  // NEW: Your coordinate sending function
  void publishCoordinate(double targetX, double targetY) {
    print("Attempting to publish coordinate to ROS..."); 
    if (_channel == null || !isConnected) {
      print("BLOCKED: Channel is null or not connected"); 
      return; 
    }

    final publishMsg = {
      "op": "publish",
      "topic": "/target_xy",
      "msg": {
        "x": targetX,
        "y": targetY,
        "z": 0.0 // Z is 0 because the buggy drives on a flat 2D floor
      }
    };
    
    try {
      _channel?.sink.add(jsonEncode(publishMsg));
      print("Successfully sent X: $targetX, Y: $targetY");
    } catch (e) {
      print("Failed to send coordinate. Connection lost: $e");
      isConnected = false;
    }
  }
  void publishGPS(double lat, double lng, double alt) {
    if (_channel == null || !isConnected) {
      return; 
    }

    final publishMsg = {
      "op": "publish",
      "topic": "/gps/fix",
      "type": "sensor_msgs/msg/NavSatFix",
      "msg": {
        "header": {"frame_id": "gps_link"},
        "latitude": lat,
        "longitude": lng,
        "altitude": alt
      }
    };
    
    try {
      _channel?.sink.add(jsonEncode(publishMsg));
    } catch (e) {
      print("Failed to send GPS. Connection lost: $e");
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