import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_driver_registration.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gari_chai/App/Users/user_dashboard.dart';
import 'package:gari_chai/App/Drivers/driver_dashboard.dart';
import 'package:gari_chai/config.dart';
import 'login.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  OTPVerificationScreen(this.phoneNumber);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false; // Loading state
  String verificationId2 = "";
  int remainingTime = 300; // 5 minutes in seconds
  Timer? timer;

  @override
  void initState() {
    super.initState();
    sendOTP();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        timer.cancel();
      }
    });
  }

  void sendOTP() {
    _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId2 = verId;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        setState(() {
          verificationId2 = verId;
        });
      },
    );
  }

  void verifyOTP(String verificationId) async {
    setState(() => isLoading = true);
    String otp = otpController.text.trim();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId2,
      smsCode: otp,
    );
    try {
      // Verify OTP with Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      //String uid = userCredential.user!.uid;
      String phoneNumber = userCredential.user!.phoneNumber ?? '';

      // Call API to check if mobile number exists
      var response = await checkUserRole(phoneNumber);

      if (response['result'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(phoneNumber: phoneNumber),
          ),
        );

        // if (response['rolename'] == 'Passenger') {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //       builder:
        //           (context) => UserDashboard(phoneNumber: widget.phoneNumber),
        //     ),
        //   );
        // } else if (response['rolename'] == 'Driver') {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => DriverDashboard()),
        //   );
        // }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDriverRegistrationScreen(phoneNumber),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false); // Hide loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid OTP, please try again")));
    }
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

  // Function to call API and check user role
  Future<Map<String, dynamic>> checkUserRole(String phoneNumber) async {
    try {
      String formattedPhone = formatPhoneNumber(phoneNumber);

      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/checkUser"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": formattedPhone}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("API call failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error calling API: $e");
    }
    return {"result": false}; // Default response if API call fails
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return "$minutes:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "🔒 ", style: TextStyle(fontSize: 24)),
              TextSpan(
                text: "OTP Verification",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Time Left: ${formatTime(remainingTime)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: remainingTime > 30 ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 55,
                  fieldWidth: MediaQuery.of(context).size.width / 8,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.blueAccent,
                ),
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: false,
                onCompleted: (value) {
                  verifyOTP(value);
                },
              ),
              SizedBox(height: 25),
              isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed:
                          remainingTime > 0
                              ? () => verifyOTP(otpController.text.trim())
                              : null, // Disable if timer ends
                      child: Text(
                        "Verify OTP",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        elevation: 12,
                        shadowColor: Colors.blueAccent.withOpacity(0.4),
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
