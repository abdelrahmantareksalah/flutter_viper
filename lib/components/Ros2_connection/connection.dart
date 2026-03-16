import 'dart:convert';
import 'dart:async'; 
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart'; 
import 'package:geolocator/geolocator.dart'; 

class RosConnection {
  WebSocketChannel? _channel;
  bool isConnected = false; 

  // The "Radio Station" that broadcasts the path to your map screen
  final _pathStreamController = StreamController<List<LatLng>>.broadcast();
  Stream<List<LatLng>> get pathStream => _pathStreamController.stream;

  // Holds the background GPS stream
  StreamSubscription<Position>? _gpsSubscription;

  void connect(String ipAddress, {Function()? onConnectionLost}) {
    disconnect(); 

    final url = 'ws://$ipAddress:9090'; 
    print("Attempting to connect to ROS at $url...");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      isConnected = true; 

      // 1. ADVERTISE JOYSTICK TOPIC
      final advertiseJoystickMsg = {
        "op": "advertise",
        "topic": "/cmd_vel",
        "type": "geometry_msgs/msg/Twist"
      };
      _channel?.sink.add(jsonEncode(advertiseJoystickMsg));

      // 2. ADVERTISE LIVE GPS TOPIC
      final advertiseGpsMsg = {
        "op": "advertise",
        "topic": "/flutter/gps",
        "type": "sensor_msgs/msg/NavSatFix"
      };
      _channel?.sink.add(jsonEncode(advertiseGpsMsg));

      // 3. ADVERTISE GOAL GPS TOPIC (Where you tap on the map)
      final advertiseGoalGpsMsg = {
        "op": "advertise",
        "topic": "/goal_gps",
        "type": "sensor_msgs/msg/NavSatFix"
      };
      _channel?.sink.add(jsonEncode(advertiseGoalGpsMsg));

      // 4. SUBSCRIBE TO CALCULATED PATH
      final subscribePathMsg = {
        "op": "subscribe",
        "topic": "/calculated_path",
        "type": "nav_msgs/msg/Path" 
      };
      _channel?.sink.add(jsonEncode(subscribePathMsg));
      // ==========================================

      // 5. START BACKGROUND GPS STREAM
      final locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Sends update every 1 meter of movement
      );

      _gpsSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        if (isConnected) {
          publishGPS(position.latitude, position.longitude, position.altitude);
        }
      });

      // 6. LISTEN TO INCOMING MESSAGES FROM ROS
      _channel?.stream.listen(
        (message) {
          final decodedMessage = jsonDecode(message);
          
          // CATCH INCOMING PATH DATA
          if (decodedMessage['topic'] == '/calculated_path') {
            try {
              List<LatLng> newPath = [];
              var poses = decodedMessage['msg']['poses'];
              
              for (var pose in poses) {
                double lat = pose['pose']['position']['x'];
                double lng = pose['pose']['position']['y'];
                newPath.add(LatLng(lat, lng));
              }
              
              // Broadcast the list of points to the Map Screen
              _pathStreamController.add(newPath);
            } catch (e) {
              print("Failed to parse incoming path: $e");
            }
          }
        },
        onError: (error) {
          print("WebSocket Network Error: $error");
          isConnected = false;
          if (onConnectionLost != null) onConnectionLost(); 
        },
        onDone: () {
          print("WebSocket Disconnected Cleanly");
          isConnected = false;
          if (onConnectionLost != null) onConnectionLost(); 
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("CRITICAL: Failed to initialize WebSocket: $e");
      isConnected = false;
      if (onConnectionLost != null) onConnectionLost();
    }
  }

  // Joystick Publish
  void publishCommand(double linearX, double angularZ) {
    if (_channel == null || !isConnected) return; 
    final publishMsg = {
      "op": "publish",
      "topic": "/cmd_vel",
      "msg": {
        "linear": {"x": linearX, "y": 0.0, "z": 0.0},
        "angular": {"x": 0.0, "y": 0.0, "z": angularZ}
      }
    };
    try { _channel?.sink.add(jsonEncode(publishMsg)); } catch (e) { isConnected = false; }
  }

  // Live GPS Publish
  void publishGPS(double lat, double lng, double alt) {
    if (_channel == null || !isConnected) return; 
    final publishMsg = {
      "op": "publish",
      "topic": "/flutter/gps",
      "msg": {
        "header": {"frame_id": "gps_link"},
        "latitude": lat,
        "longitude": lng,
        "altitude": alt
      }
    };
    try { _channel?.sink.add(jsonEncode(publishMsg)); } catch (e) { isConnected = false; }
  }

  // Goal GPS Publish (Map screen tap)
  void publishGoalGPS(double lat, double lng) {
    if (_channel == null || !isConnected) return; 
    final publishMsg = {
      "op": "publish",
      "topic": "/goal_gps",
      "msg": {
        "header": {"frame_id": "goal_link"},
        "latitude": lat,
        "longitude": lng,
        "altitude": 0.0
      }
    };
    try {
      _channel?.sink.add(jsonEncode(publishMsg));
    } catch (e) {
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
      
      // KILL GPS STREAM TO SAVE BATTERY
      _gpsSubscription?.cancel();
      _gpsSubscription = null;
    }
  }
  // Send System Commands (like Start/Stop Recording)
  void sendSystemCommand(String command) {
    if (_channel == null || !isConnected) return; 
    final publishMsg = {
      "op": "publish",
      "topic": "/system/command",
      "type": "std_msgs/msg/String",
      "msg": {
        "data": command
      }
    };
    try { 
      _channel?.sink.add(jsonEncode(publishMsg)); 
    } catch (e) { 
      isConnected = false; 
    }
  }
}

final rosConnection = RosConnection();