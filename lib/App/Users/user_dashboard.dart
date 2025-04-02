import 'package:flutter/material.dart';
import 'search_page.dart';
import 'search_page_trip.dart';
import 'package:gari_chai/App/AppServices/home_page.dart';
import 'package:gari_chai/App/AppServices/services_page.dart';
import 'package:gari_chai/App/AppServices/activity_page.dart';
import 'package:gari_chai/App/AppServices/profile_page.dart';

class UserDashboard extends StatefulWidget {
  final String phoneNumber;

  UserDashboard({required this.phoneNumber});
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gari-Chai"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Top Section with Buttons (50%)
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildSuggestionButton("Trip", Icons.directions_car),
                  _buildSuggestionButton("Reserve", Icons.calendar_today),
                  _buildSuggestionButton("CNG", Icons.electric_car),
                  _buildSuggestionButton("Moto", Icons.motorcycle),
                  _buildSuggestionButton("Rentals", Icons.car_rental),
                  _buildSuggestionButton("Intercity", Icons.location_city),
                  _buildSuggestionButton("Relocate", Icons.swap_horiz),
                  _buildSuggestionButton("Courier", Icons.local_shipping),
                ],
              ),
            ),
          ),

          // Divider Line
          //Divider(thickness: 2, color: Colors.grey.shade300),
          //Divider(thickness: 2),

          // Search Box (Placed Right Below the Divider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Container(
              height: 70, // Increased height for better visibility
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Search Area (60%)
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchPage()),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                        ), // Adjusted padding for better alignment
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.blue, size: 24),
                            SizedBox(width: 10),
                            Text(
                              "Where to go?",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Divider (Pipe)
                  Container(height: 40, width: 1, color: Colors.grey),

                  // Booking Button (40%)
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchPageTrip(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                        ), // Adjusted padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Booking",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show Selected Date & Time
                  // if (selectedDateTime != null)
                  //   Text(
                  //     "Selected Time: $selectedDateTime",
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.build),
                label: "Services",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: "Activity",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget for Suggestion Buttons
  Widget _buildSuggestionButton(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(3, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4, // Adaptive width
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(12),
              backgroundColor: Colors.blue.shade100,
              foregroundColor: const Color.fromARGB(255, 54, 78, 114),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 25),
                SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ), // Adjust font size for better fit
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
