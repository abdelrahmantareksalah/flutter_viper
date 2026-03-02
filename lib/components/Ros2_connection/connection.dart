import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RosConnection {
  WebSocketChannel? _channel;
  String? currentIp; // Add this

  void connect(String ipAddress) {
    currentIp = ipAddress; // Store it
    final url = 'ws://$ipAddress:9090';
    
    print("Attempting to connect to ROS at $url...");
    _channel = WebSocketChannel.connect(Uri.parse(url));

    // Listen for incoming messages from the car
    _channel?.stream.listen(
      (message) {
        final decodedMessage = jsonDecode(message);
        // Check if the message is from the topic we care about
        if (decodedMessage['op'] == 'publish' && decodedMessage['topic'] == '/chatter') {
          print('Received message from car: ${decodedMessage['msg']['data']}');
        }
      },
      onError: (error) => print("WebSocket Error: $error"),
      onDone: () => print("WebSocket Disconnected"),
    );
  }

  // 2. Subscribe to a topic to listen to the car
  void subscribeToChatter() {
    final subscribeMsg = {
      "op": "subscribe",
      "topic": "/chatter",
      "type": "std_msgs/String"
    };
    // Send the JSON command to rosbridge
    _channel?.sink.add(jsonEncode(subscribeMsg));
    print("Subscribed to /chatter");
  }

  // 3. Publish a command to the car (like FORWARD or LEFT)
  void publishCommand(double linearX, double angularZ) {
    if (_channel == null) return;

    final publishMsg = {
      "op": "publish",
      "topic": "/cmd_vel", // Match the ROS node topic!
      "msg": {
        "linear": {"x": linearX, "y": 0.0, "z": 0.0},
        "angular": {"x": 0.0, "y": 0.0, "z": angularZ}
      }
    };
    
    _channel?.sink.add(jsonEncode(publishMsg));
  }

  // 4. Close the connection when done
  void disconnect() {
    _channel?.sink.close();
    print("Disconnected from ROS");
  }
}

// Create a global instance of this connection so all screens can use it
final rosConnection = RosConnection();