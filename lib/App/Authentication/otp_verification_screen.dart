import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_driver_registration.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:gari_chai/App/Users/user_dashboard.dart';
import 'package:gari_chai/App/Drivers/driver_dashboard.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  OTPVerificationScreen(this.verificationId);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  // void verifyOTP() async {
  //   String otp = otpController.text.trim();
  //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //     verificationId: widget.verificationId,
  //     smsCode: otp,
  //   );

  //   try {
  //     UserCredential userCredential = await _auth.signInWithCredential(
  //       credential,
  //     );
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (context) =>
  //                 UserDriverRegistrationScreen(userCredential.user!.uid),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Invalid OTP")));
  //   }
  // }

  void verifyOTP() async {
    String otp = otpController.text.trim();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
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
        if (response['rolename'] == 'Passenger') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserDashboard()),
          );
        } else if (response['rolename'] == 'Driver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverDashboard()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDriverRegistrationScreen(phoneNumber),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid OTP")));
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
        Uri.parse("http://10.0.2.2:5000/api/checkUser"),
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
              // OTP Field without Shadow
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  // Removed shadow
                ),
                padding: EdgeInsets.all(8),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 70,
                    fieldWidth: 65,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    selectedColor: Colors.blueAccent,
                    activeFillColor: Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  enableActiveFill: false,
                  onCompleted: (v) {
                    print("Completed OTP: $v");
                  },
                  onChanged: (value) {
                    print(value);
                  },
                ),
              ),
              SizedBox(height: 25),

              // Bigger Button with Shadow
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: verifyOTP,
                  child: Text(
                    "Verify OTP",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    elevation: 12, // Increased shadow effect for the button
                    shadowColor: Colors.blueAccent.withOpacity(
                      0.4,
                    ), // Button shadow
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
