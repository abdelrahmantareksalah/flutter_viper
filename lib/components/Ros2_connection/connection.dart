import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RosConnection {
  WebSocketChannel? _channel;

  void connect(String ipAddress) {
    // Port 9090 is the default for rosbridge
    final url = 'ws://$ipAddress:9090'; 
    _channel = WebSocketChannel.connect(Uri.parse(url));
    print("Connecting to $url");
  }

  void publishCommand(double linearX, double angularZ) {
    if (_channel == null) return;

    // This JSON matches exactly what rosbridge expects for a Twist message
    final msg = {
      "op": "publish",
      "topic": "/cmd_vel",
      "msg": {
        "linear": {"x": linearX, "y": 0.0, "z": 0.0},
        "angular": {"x": 0.0, "y": 0.0, "z": angularZ}
      }
    };

    _channel!.sink.add(jsonEncode(msg));
  }

  void disconnect() {
    _channel?.sink.close();
  }
}

final rosConnection = RosConnection();