import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RosConnection {
  WebSocketChannel? _channel;

  // 1. Connect to the ROS car's IP address
  void connect(String ipAddress) {
    // Replace 'localhost' with your car's actual Wi-Fi IP address later
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
  void publishCommand(String command) {
    if (_channel == null) {
      print("Cannot send command, not connected to ROS!");
      return;
    }

    final publishMsg = {
      "op": "publish",
      "topic": "/chatter", // We will likely change this to a /cmd_vel topic later!
      "msg": {
        "data": command
      }
    };
    
    // Send the JSON command to rosbridge
    _channel?.sink.add(jsonEncode(publishMsg));
    print('Command sent to car: $command');
  }

  // 4. Close the connection when done
  void disconnect() {
    _channel?.sink.close();
    print("Disconnected from ROS");
  }
}

// Create a global instance of this connection so all screens can use it
final rosConnection = RosConnection();