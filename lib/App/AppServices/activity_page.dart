import 'package:flutter/material.dart';
import 'package:gari_chai/App/AppServices/home_page.dart';
import 'package:gari_chai/App/AppServices/services_page.dart';
import 'package:gari_chai/App/AppServices/profile_page.dart';

class ActivityPage extends StatefulWidget {
  final String phoneNumber; // Accepts mobile number as parameter

  ActivityPage({required this.phoneNumber});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
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

  @override
  Widget build(BuildContext context) {
    // List of services
    final List<String> services = [
      "Service 1: Web Development",
      "Service 2: Mobile App Development",
      "Service 3: UI/UX Design",
      "Service 4: Cloud Computing",
      "Service 5: Machine Learning",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Activity Logs"),
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     // Ensure it goes back to the previous page in the stack
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading for the Activity
            Text(
              "Activity",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),

            // Heading for Services
            Text(
              "Our Services",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 10),

            // List of Services
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text(
                        services[index],
                        style: TextStyle(fontSize: 18),
                      ),
                      leading: Icon(Icons.check_circle, color: Colors.blue),
                    ),
                  );
                },
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
