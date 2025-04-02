import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gari_chai/App/Authentication/phone_auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gari Chai',
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: ThemeMode.system, // Automatically switch based on device settings
      home: PhoneAuthScreen(),
    );
  }
}
