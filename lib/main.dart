import 'package:flutter/material.dart';
import 'package:flutter_viper/screens/command/CommandScreen.dart';
import 'package:flutter_viper/screens/home/HomeScreen.dart';
import 'package:flutter_viper/screens/manualControl/manualControlScreen.dart';
import 'package:flutter_viper/screens/map/MapScreen.dart';
import 'package:flutter_viper/screens/createPath/CreatePathScreen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// 1. We only import the connection to have it in the project scope, 
// but we don't put it in the routes list because it's not a "Screen".
import 'package:flutter_viper/components/Ros2_connection/connection.dart';

void main() {
  // 2. Ensuring the Flutter engine is ready before we touch hardware/plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Keep the screen on so the phone doesn't lock while driving the robot!
  WakelockPlus.enable(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides that red "Debug" tag
      title: 'VIPER',
      theme: ThemeData(
        // FIXED: Added "ColorScheme" before .fromSeed
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/', // Tells the app to start at the Home Screen
      routes: {
        '/': (context) =>  HomeScreen(),
        '/map': (context) =>  MapScreen(),
        '/createPath': (context) =>  CreatePathScreen(),
        '/command': (context) =>  CommandScreen(),
        '/manualControl': (context) => const ManualControlScreen(),
        // REMOVED: '/Ros2_connection'. You can't navigate to a logic class!
      },
    );
  }
}