import 'dart:convert';
import 'dart:async'; 
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart'; 
import 'package:sensors_plus/sensors_plus.dart'; 
import 'package:geolocator/geolocator.dart'; // Added for continuous GPS

class RosConnection {
  WebSocketChannel? _channel;
  bool isConnected = false; 

  // The "Radio Station" that broadcasts the path to your map screen
  final _pathStreamController = StreamController<List<LatLng>>.broadcast();
  Stream<List<LatLng>> get pathStream => _pathStreamController.stream;

  // Holds the background sensor streams
  StreamSubscription<MagnetometerEvent>? _magSubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  StreamSubscription<Position>? _gpsSubscription; // Added GPS stream

  // Cache the latest accelerometer readings to pair with the gyro
  double _accX = 0.0, _accY = 0.0, _accZ = 0.0;

  void connect(String ipAddress, {Function()? onConnectionLost}) {
    disconnect(); 

    final url = 'ws://$ipAddress:9090'; 
    print("Attempting to connect to ROS at $url...");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      isConnected = true; 

      // 1. ADVERTISE JOYSTICK
      final advertiseMsg = {
        "op": "advertise",
        "topic": "/cmd_vel",
        "type": "geometry_msgs/msg/Twist"
      };
      _channel?.sink.add(jsonEncode(advertiseMsg));
      
      // 2. ADVERTISE COORDINATE TOPIC
      final advertisePointMsg = {
        "op": "advertise",
        "topic": "/target_xy",
        "type": "geometry_msgs/msg/Point"
      };
      _channel?.sink.add(jsonEncode(advertisePointMsg));

      // 3. ADVERTISE LIVE GPS TOPIC
      final advertiseGpsMsg = {
        "op": "advertise",
        "topic": "/gps/fix",
        "type": "sensor_msgs/msg/NavSatFix"
      };
      _channel?.sink.add(jsonEncode(advertiseGpsMsg));

      // 4. ADVERTISE GOAL GPS TOPIC (Where you tap on the map)
      final advertiseGoalGpsMsg = {
        "op": "advertise",
        "topic": "/goal_gps",
        "type": "sensor_msgs/msg/NavSatFix"
      };
      _channel?.sink.add(jsonEncode(advertiseGoalGpsMsg));

      // 5. SUBSCRIBE TO CALCULATED PATH
      final subscribePathMsg = {
        "op": "subscribe",
        "topic": "/calculated_path",
        "type": "nav_msgs/msg/Path" 
      };
      _channel?.sink.add(jsonEncode(subscribePathMsg));

      // 6. ADVERTISE MAGNETOMETER (COMPASS) TOPIC
      final advertiseMagMsg = {
        "op": "advertise",
        "topic": "/phone/mag",
        "type": "sensor_msgs/msg/MagneticField"
      };
      _channel?.sink.add(jsonEncode(advertiseMagMsg));

      // 7. ADVERTISE IMU (ACCEL + GYRO) TOPIC
      final advertiseImuMsg = {
        "op": "advertise",
        "topic": "/phone/imu",
        "type": "sensor_msgs/msg/Imu"
      };
      _channel?.sink.add(jsonEncode(advertiseImuMsg));
      // ==========================================

      // 8. START BACKGROUND COMPASS STREAM
      _magSubscription = magnetometerEventStream().listen((MagnetometerEvent event) {
        if (isConnected) {
          // Convert microTeslas to Teslas
          publishMagnetometer(
            event.x / 1000000.0, 
            event.y / 1000000.0, 
            event.z / 1000000.0
          );
        }
      });

      // 9. START BACKGROUND ACCELEROMETER STREAM (Includes Gravity)
      _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
        _accX = event.x;
        _accY = event.y;
        _accZ = event.z;
      });

      // 10. START BACKGROUND GYROSCOPE STREAM & PUBLISH IMU
      _gyroSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
        if (isConnected) {
          publishIMU(event.x, event.y, event.z);
        }
      });

      // 11. START BACKGROUND GPS STREAM
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

      // 12. LISTEN TO INCOMING MESSAGES FROM ROS
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

  // Joystick publish
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

  // Local Coordinate publish
  void publishCoordinate(double targetX, double targetY) {
    if (_channel == null || !isConnected) return; 
    final publishMsg = {
      "op": "publish",
      "topic": "/target_xy",
      "msg": {"x": targetX, "y": targetY, "z": 0.0}
    };
    try { _channel?.sink.add(jsonEncode(publishMsg)); } catch (e) { isConnected = false; }
  }

  // Live GPS publish
  void publishGPS(double lat, double lng, double alt) {
    if (_channel == null || !isConnected) return; 
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
    try { _channel?.sink.add(jsonEncode(publishMsg)); } catch (e) { isConnected = false; }
  }

  // Goal GPS Publish (Map screen tap)
  void publishGoalGPS(double lat, double lng) {
    if (_channel == null || !isConnected) return; 
    final publishMsg = {
      "op": "publish",
      "topic": "/goal_gps",
      "type": "sensor_msgs/msg/NavSatFix",
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
  
  // Magnetometer Publish
  void publishMagnetometer(double x, double y, double z) {
    if (_channel == null || !isConnected) return; 
    
    final publishMsg = {
      "op": "publish",
      "topic": "/phone/mag",
      "type": "sensor_msgs/msg/MagneticField",
      "msg": {
        "header": {"frame_id": "phone_link"},
        "magnetic_field": {"x": x, "y": y, "z": z},
        "magnetic_field_covariance": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] 
      }
    };
    try { 
      _channel?.sink.add(jsonEncode(publishMsg)); 
    } catch (e) { 
      isConnected = false; 
    }
  }

  // IMU Publish (Combined Accel and Gyro)
  void publishIMU(double gyroX, double gyroY, double gyroZ) {
    if (_channel == null || !isConnected) return; 
    
    final publishMsg = {
      "op": "publish",
      "topic": "/phone/imu",
      "type": "sensor_msgs/msg/Imu",
      "msg": {
        "header": {"frame_id": "phone_link"},
        "orientation_covariance": [-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        "angular_velocity": {"x": gyroX, "y": gyroY, "z": gyroZ},
        "angular_velocity_covariance": [0.01, 0.0, 0.0, 0.0, 0.01, 0.0, 0.0, 0.0, 0.01],
        "linear_acceleration": {"x": _accX, "y": _accY, "z": _accZ},
        "linear_acceleration_covariance": [0.01, 0.0, 0.0, 0.0, 0.01, 0.0, 0.0, 0.0, 0.01]
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
      
      // KILL ALL SENSOR STREAMS TO SAVE BATTERY
      _magSubscription?.cancel();
      _magSubscription = null;
      _accelSubscription?.cancel();
      _accelSubscription = null;
      _gyroSubscription?.cancel();
      _gyroSubscription = null;
      _gpsSubscription?.cancel();
      _gpsSubscription = null;
    }
  }
}

final rosConnection = RosConnection();