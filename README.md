# flutter_viper

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Hureka Buggy - Phase 1 Documentation
Goal: Build a custom Flutter mobile application to manually teleoperate a ROS 2 robot over Wi-Fi using WebSockets.

🏗️ System Architecture
Frontend: Flutter (Dart) mobile app for Android/tablet.

Backend / Middleware: ROS 2 running inside Ubuntu (WSL2 / Raspberry Pi).

Bridge: rosbridge_server (translates WebSockets to ROS 2 topics).

Network: Tailscale (Virtual Private Mesh Network) to bypass Windows firewalls and allow connection from any Wi-Fi network.

🛠️ Key Components Built
1. The ROS 2 Connection Class (connection.dart)
What it does: Uses the web_socket_channel package to open a live pipe to ws://[IP_ADDRESS]:9090.

Message Format: Communicates using JSON.

Advertising: Before sending data, the app must "advertise" the topic to ROS 2 by sending a JSON payload declaring the topic name (/cmd_vel) and type (geometry_msgs/msg/Twist).

2. The Manual Control Screen (manualControlScreen.dart)
What it does: The UI for driving the buggy.

Joystick: Uses flutter_joystick to capture thumb movements (-1.0 to 1.0).

Math Mapping:

Pushing UP (Negative Y) = Forward (Positive Linear X).

Pushing RIGHT (Positive X) = Turning Right (Negative Angular Z).

E-Stop: A red emergency button that instantly publishes 0.0 to all axes to kill momentum.

🐛 Major Problems Solved (The "Don't Forget This" Section)
Problem 1: The App Silently Blocked its Own Messages
The Bug: The joystick math was printing in Flutter, but no data reached the WSL terminal. The app kept printing BLOCKED: Channel is null or not connected.

The Cause: In our original code, we told Flutter to wait for a "Hello" message from ROS 2 before flipping isConnected = true. However, rosbridge does not send confirmation messages; it just silently opens the connection. Because Flutter never got a greeting, it assumed the connection failed and blocked the publishCommand function.

The Fix: Moved isConnected = true; to the very top of the connection sequence, immediately after opening the WebSocket channel.

Problem 2: WSL Networking and Changing IPs
The Bug: The tablet couldn't reach the WSL Linux environment because WSL hides behind a virtual router in Windows, and Windows Firewall blocks incoming mobile traffic.

The Old Fix: Used Windows netsh interface portproxy to route traffic. Issue: The WSL IP changes every time the PC restarts.

The Permanent Fix: Installed Tailscale inside WSL and on the Android tablet. This creates a secure tunnel and gives the Linux machine a permanent 100.x.x.x IP address. The app can now connect from any Wi-Fi network or cellular hotspot.

Problem 3: Flutter UI Layout Crashes (Bottom Overflow)
The Bug: Adding buttons under the joystick caused a "Bottom Overflowed by X pixels" yellow tape error on the tablet screen.

The Cause: Columns in Flutter try to expand, and if the screen is too small, they crash instead of scrolling.

The Fix: Wrapped the main body in a SingleChildScrollView and constrained it with a SizedBox equal to the screen height (MediaQuery.of(context).size.height).

🚀 How to Run the Project (Standard Operating Procedure)
Start the Network: Ensure Tailscale is running on the tablet and inside the Ubuntu environment (sudo tailscale up).

Start ROS 2 Bridge: In Ubuntu, run:

Bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml
Start the Listener (Optional Debugging): In a second Ubuntu terminal, run:

Bash
ros2 topic echo /cmd_vel
Launch the App: Run the Flutter app on the tablet, navigate to the Manual Control screen, and move the joystick.

🗺️ Phase 2 Roadmap: Autonomous Navigation
Phase 2 will transition the buggy from manual RC to GPS-waypoint autonomy.

Required Hardware & Sensor Fusion:

GPS Node: Provides absolute global positioning (slow, 1-10Hz, prone to wandering).

Magnetometer (Compass): Specifically the GY-273 / QMC5883L (Note: Use the QMC library, not HMC!). Essential for determining absolute heading (North/South). Must be calibrated to ignore the buggy's DC motor magnetic interference.

Wheel Encoders (Odometry): Mandatory for calculating precise forward distance traveled.

The Brain (Extended Kalman Filter): We will use the ROS 2 robot_localization package to fuse the GPS, Compass, and Encoders together. The IMU predicts movement between GPS pings, and the GPS corrects the IMU's drift.