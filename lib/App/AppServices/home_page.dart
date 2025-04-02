import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              "Welcome to the App!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),

            // Brief Description
            Text(
              "Explore the various features and services we offer. Choose an option below to get started.",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),

            // Action Cards to Navigate to Other Pages
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildHomePageCard(
                    context,
                    title: "Profile",
                    icon: Icons.person,
                    onTap: () {
                      // Navigate to Profile Page
                    },
                  ),
                  _buildHomePageCard(
                    context,
                    title: "Services",
                    icon: Icons.build,
                    onTap: () {
                      // Navigate to Services Page
                    },
                  ),
                  _buildHomePageCard(
                    context,
                    title: "Activity",
                    icon: Icons.list_alt,
                    onTap: () {
                      // Navigate to Activity Page
                    },
                  ),
                  _buildHomePageCard(
                    context,
                    title: "Settings",
                    icon: Icons.settings,
                    onTap: () {
                      // Navigate to Settings Page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create cards for the Home Page
  Widget _buildHomePageCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blueAccent),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
