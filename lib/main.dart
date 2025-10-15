import 'package:flutter/material.dart';
import 'package:smart_cam_app/screens/home_screen.dart';
import 'package:smart_cam_app/screens/welcome_screen.dart';
import 'package:smart_cam_app/screens/camera_screen.dart';
import 'package:smart_cam_app/screens/settings_screen.dart';
import 'package:smart_cam_app/screens/history_screen.dart';
import 'package:smart_cam_app/screens/firebase_test_screen.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Cam App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/welcome',
      routes: {
        '/': (context) => const HomeScreen(),
        '/welcome': (context) => const WelcomeScreen(), // name and age will be passed later
        '/camera': (context) => const CameraScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/firebase-test': (context) => const FirebaseTestScreen(),
      },
    );
  }
}
