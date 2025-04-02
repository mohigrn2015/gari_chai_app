import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gari_chai/App/Users/user_dashboard.dart';
import 'package:gari_chai/App/Drivers/driver_dashboard.dart';
import 'package:gari_chai/config.dart';

class UserDriverRegistrationScreen extends StatefulWidget {
  final String phoneNumber;
  const UserDriverRegistrationScreen(this.phoneNumber, {super.key});

  @override
  _UserDriverRegistrationScreenState createState() =>
      _UserDriverRegistrationScreenState();
}

class _UserDriverRegistrationScreenState
    extends State<UserDriverRegistrationScreen> {
  //final _formKey = GlobalKey<FormState>(); // Form Key for validation
  String selectedRole = "1"; // Default: Passenger
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController personNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController nidController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController drivingLicenseController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController refreshTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-fill username and mobile number
    usernameController.text = widget.phoneNumber;
    mobileNumberController.text = widget.phoneNumber;
  }

  String formatPhoneNumber(String phoneNumber) {
    // Remove '+' if present
    phoneNumber = phoneNumber.replaceAll('+', '');

    // If the number starts with '0', replace it with '88'
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '88${phoneNumber.substring(0)}';
    }

    return phoneNumber;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    // Email Regex Pattern
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  /// Function to register a new user
  Future<void> registerUser() async {
    //if (_formKey.currentState!.validate()) {
    String formattedPhone = formatPhoneNumber(usernameController.text.trim());
    Map<String, dynamic> requestData = {
      "username": formattedPhone,
      "password": passwordController.text.trim(),
      "usertype": selectedRole == "1" ? "1" : "2",
      "personname": personNameController.text.trim(),
      "email": emailController.text.trim(),
      "createdby": formattedPhone,
      "mobilenumber": formattedPhone,
    };

    if (selectedRole == "2") {
      // Add extra fields for Driver
      requestData.addAll({
        "nidnumber": nidController.text.trim(),
        "address": addressController.text.trim(),
        "drivinglicense": drivingLicenseController.text.trim(),
        "refreshtoken": "",
      });
    }
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${responseData.message}")));

        // Navigate based on role
        if (selectedRole == "1") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => UserDashboard(phoneNumber: widget.phoneNumber),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverDashboard()),
          );
        }
      } else {
        var responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration Failed! ${responseData.message}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network Error! Check your connection.$e")),
      );
    }
    // } else {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text("Required data is missing")));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "📝 Registration",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Dropdown with Curve Style
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.blue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(border: InputBorder.none),
                    items: [
                      DropdownMenuItem(
                        value: "1",
                        child: Text("As a Passenger"),
                      ),
                      DropdownMenuItem(value: "2", child: Text("As a Driver")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),

                /// Username (Auto-filled & Uneditable)
                TextField(
                  controller: usernameController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 15),

                /// Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),

                /// Common Fields
                TextField(
                  controller: personNameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: validateEmail, // Apply validation
                ),
                SizedBox(height: 15),

                /// Extra Fields for Driver
                if (selectedRole == "2") ...[
                  ///SizedBox(height: 15),
                  TextField(
                    controller: nidController,
                    decoration: InputDecoration(
                      labelText: "NID Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),

                  TextField(
                    controller: drivingLicenseController,
                    decoration: InputDecoration(
                      labelText: "Driving License",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),

                  // TextField(
                  //   controller: refreshTokenController,
                  //   decoration: InputDecoration(
                  //     labelText: "Refresh Token",
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                  SizedBox(height: 15),
                ],

                /// Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: registerUser,
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
