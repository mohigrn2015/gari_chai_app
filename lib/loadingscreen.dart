import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gari_chai/App/Authentication/user_driver_registration.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gari_chai/App/Users/user_dashboard.dart';
import 'package:gari_chai/App/Drivers/driver_dashboard.dart';
import 'package:gari_chai/config.dart';

class LoadingScreen extends StatefulWidget {
  final String phoneNumber;
  LoadingScreen(this.phoneNumber);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    try {
      String formattedPhone = widget.phoneNumber.replaceAll('+', '');
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/checkUser"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": formattedPhone}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['result'] == true) {
          if (data['rolename'] == 'Passenger') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserDashboard()),
            );
          } else if (data['rolename'] == 'Driver') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DriverDashboard()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => UserDriverRegistrationScreen(widget.phoneNumber),
            ),
          );
        }
      } else {
        showError("Failed to check user role.");
      }
    } catch (e) {
      showError("Error: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context); // Go back to OTP screen on error
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // ✅ Show loading while checking role
      ),
    );
  }
}
