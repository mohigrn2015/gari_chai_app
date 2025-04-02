import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gari_chai/config.dart';
import 'package:gari_chai/App/AppServices/home_page.dart';
import 'package:gari_chai/App/AppServices/services_page.dart';
import 'package:gari_chai/App/AppServices/activity_page.dart';

class ProfilePage extends StatefulWidget {
  final String phoneNumber; // Accepts mobile number as parameter

  ProfilePage({required this.phoneNumber});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true; // Loading indicator
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Prevent reloading same page

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomePage();
        break;
      case 1:
        nextPage = ServicesPage(phoneNumber: widget.phoneNumber);
        break;
      case 2:
        nextPage = ActivityPage(phoneNumber: widget.phoneNumber);
        break;
      case 3:
        nextPage = ProfilePage(phoneNumber: widget.phoneNumber);
        break;
      default:
        return;
    }

    // Navigate to the selected page and remove previous screen from stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
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

  // Function to fetch user data from API
  Future<void> fetchUserInfo() async {
    String formattedPhone = formatPhoneNumber(widget.phoneNumber);
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/getUserInfo"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": formattedPhone}), // Sending mobile number
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['result'] == true && responseData['data'] != null) {
          setState(() {
            userData = responseData['data']; // Extract "data" from response
            isLoading = false;
          });
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch data');
        }
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (error) {
      print("Error fetching user info: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // ✅ Show loading indicator
              : userData == null
              ? Center(
                child: Text("Failed to load profile data"),
              ) // Show error message if no data
              : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150', // ✅ Replace with actual profile image
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // User's Name
                    Center(
                      child: Text(
                        userData!['personname'] ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // User's Role
                    Center(
                      child: Text(
                        "User Type: ${userData!['rolename'] ?? 'N/A'}",
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Contact Information Section
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.green),
                      title: Text(
                        userData!['mobilenumber'] ?? 'No Phone Number',
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.orange),
                      title: Text(userData!['address'] ?? 'No Address'),
                    ),
                    ListTile(
                      leading: Icon(Icons.credit_card, color: Colors.blue),
                      title: Text("NID: ${userData!['nidnumber'] ?? 'N/A'}"),
                    ),

                    if (userData!['drivinglisence'] != null)
                      ListTile(
                        leading: Icon(Icons.badge, color: Colors.purple),
                        title: Text(
                          "Driving License: ${userData!['drivinglisence']}",
                        ),
                      ),

                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.red),
                      title: Text(
                        "Joined On: ${userData!['createDate']?.split('T')[0] ?? 'N/A'}",
                      ),
                    ),
                  ],
                ),
              ),

      // ✅ Add Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Services"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Activity",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
