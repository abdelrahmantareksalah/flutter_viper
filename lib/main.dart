import 'package:flutter/material.dart';
import 'package:flutter_viper/screens/navigate/navScreen.dart';
import 'package:flutter_viper/screens/home/HomeScreen.dart';
import 'package:flutter_viper/screens/manualControl/manualControlScreen.dart';
import 'package:flutter_viper/screens/map/MapScreen.dart';
import 'package:flutter_viper/screens/createPath/CreatePathScreen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_viper/components/Ros2_connection/connection.dart';
import 'package:flutter_viper/screens/connection_screen_list/connection_screen_list.dart';

void main() {
  // Ensuring the Flutter engine is ready before we touch hardware/plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // Keep the screen on so the phone doesn't lock while driving the robot!
  WakelockPlus.enable(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides that red "Debug" tag
      title: 'Hureka', // You can change this to your new app name
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, primary: Colors.blue),
        useMaterial3: true,  
      ),
        
      
      // NEW FLOW: We start at the IP Setup Screen instead of the Home Screen
      initialRoute: '/', 
      
      routes: {
        // 1. The very first screen is now your IP setup / Robot Selection
        '/': (context) =>  ConnectionListScreen(), // (Change to DeviceSelectionScreen() if you kept the old class name)
        // 2. Once connected, it takes you to the Home Menu
        '/home': (context) => HomeScreen(),
        // 3. All your other awesome features
        '/map': (context) => MapScreen(),
        '/createPath': (context) => CreatePathScreen(),
        '/navigation': (context) => NavigationScreen(),
        '/manualControl': (context) => ManualControlScreen(),
      },
    );
  }
}