import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Attendance"),
        backgroundColor: Colors.blue, // Customize app bar color
        elevation: 0, // Remove app bar shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // User Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Replace with actual image URL
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Shubham Dev",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "shubham.01919051722@ipu.ac.in",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            // Welcome Message
            Text(
              "Hi, Shubham.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Welcome to your Class",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
              ),
            ),

            SizedBox(height: 30),

            // Today's Classes Section
            Text(
              "Today's Classes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  _buildClassItem("DA", "Data Analytics", "09:00 am"),
                  _buildClassItem("OS", "Operating System", "10:00 am"),
                  _buildClassItem("DS", "Data Structure", "11:00 am"),
                  _buildClassItem("F", "Flutter", "12:00 pm"),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Other Options
            _buildOptionItem("Check Attendance Report"),
            _buildOptionItem("Faculty Details"),
            _buildOptionItem("Class Details"),
          ],
        ),
      ),
    );
  }

  Widget _buildClassItem(String initial, String className, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          initial,
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(className),
      trailing: Text(time),
    );
  }

  Widget _buildOptionItem(String title) {
    return InkWell(
      // Wrap with InkWell for tap effect
      onTap: () {}, // Empty onTap for now
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
