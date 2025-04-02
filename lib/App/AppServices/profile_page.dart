import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data for the profile
    final String userName = "Mohiuddin";
    final String email = "mohigrn2015@gmail.com";
    final String phone = "+880 1964 139 056";
    final String address = "Nurnagar, Shyamnagar, Satkhira";

    return Scaffold(
      appBar: AppBar(title: Text("Profile Page")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://www.example.com/path/to/your/profile_picture.jpg', // Replace with the user's profile image URL
                ),
              ),
            ),
            SizedBox(height: 20),

            // User's Name
            Center(
              child: Text(
                userName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 10),

            // User's Email
            Center(
              child: Text(
                email,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 20),

            // Heading for Contact Information
            Text(
              "Contact Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 10),

            // Contact Details (Phone and Address)
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text(phone),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.orange),
              title: Text(address),
            ),
          ],
        ),
      ),
    );
  }
}
