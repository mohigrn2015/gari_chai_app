import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
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
        title: Text("Activity Page"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Ensure it goes back to the previous page in the stack
            Navigator.pop(context);
          },
        ),
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
    );
  }
}
