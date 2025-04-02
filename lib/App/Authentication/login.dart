import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gari_chai/config.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gari_chai/App/Users/user_dashboard.dart';
import 'package:gari_chai/App/Drivers/driver_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String phoneNumber;
  const LoginScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool isRememberMe = false;
  bool isPasswordVisible = false;

  String formatPhoneNumber(String phoneNumber) {
    // Remove '+' if present
    phoneNumber = phoneNumber.replaceAll('+', '');

    // If the number starts with '0', replace it with '88'
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '88${phoneNumber.substring(0)}';
    }

    return phoneNumber;
  }

  void login() async {
    // Request Payload
    String deviceId = await getDeviceId(); // Fetch Device ID
    String password = passwordController.text.trim(); // Get password input
    String formattedPhone = formatPhoneNumber(widget.phoneNumber);
    // Request Payload
    Map<String, String> requestBody = {
      "username": formattedPhone, // Phone number from input
      "password": password, // Password from user input
      "deviceid": deviceId, // Dynamically fetched device ID
    };

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Response Test: $requestBody");
      print("Response Test Status: ${response.statusCode}");
      // Check for success (Assuming 200 means success)
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Response Test: $responseData");
        if (responseData['result'] == true) {
          if (responseData['data']['rolename'] == 'Passenger') {
            // Example: Save token if returned
            String? token = responseData['data']["access_token"];
            if (token != null) {
              print("Token Test: $token");
              // Store token securely (e.g., SharedPreferences)
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => UserDashboard(phoneNumber: widget.phoneNumber),
              ),
            );
          } else if (responseData['data']['rolename'] == 'Driver') {
            // Example: Save token if returned
            String? token = responseData['data']["access_token"];
            if (token != null) {
              print("Token Test: $token");
              // Store token securely (e.g., SharedPreferences)
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DriverDashboard()),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Invalid User role!")));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? "Login failed!")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid credentials, please try again!"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  // Method to get device ID
  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Unique Android device ID
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? "unknown-device";
      }
    } catch (e) {
      print("Error getting device ID: $e");
    }
    return "unknown-device";
  }

  void forgotPassword() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Forgot Password Clicked!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username Field (Non-editable)
              TextField(
                controller: TextEditingController(text: widget.phoneNumber),
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isRememberMe,
                        onChanged: (value) {
                          setState(() {
                            isRememberMe = value!;
                          });
                        },
                      ),
                      const Text("Remember Me", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  TextButton(
                    onPressed: forgotPassword,
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 60, // Bigger height
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
