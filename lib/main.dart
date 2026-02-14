import 'package:flutter/material.dart';
import 'package:flutter_viper/screens/command/CommandScreen.dart';
import 'package:flutter_viper/screens/home/HomeScreen.dart';
import 'package:flutter_viper/screens/map/MapScreen.dart';
import 'package:flutter_viper/screens/createPath/CreatePathScreen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIPER',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue, primary: Colors.blue),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/map': (context) => MapScreen(),
        '/createPath': (context) => CreatePathScreen(),
        '/command': (context) => CommandScreen(),
      },
    );
  }
}
