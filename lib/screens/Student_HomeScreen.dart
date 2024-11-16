import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Attendance",
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // User Profile Section with enhanced styling
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue.shade400,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shubham Dev",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "shubham.01919051722@ipu.ac.in",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Welcome Message with enhanced styling
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, Shubham.",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Welcome to your Class",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Today's Classes Section
              Text(
                "Today's Classes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildClassItem("DA", "Data Analytics", "09:00 am",
                        Colors.blue.shade400),
                    Divider(height: 1),
                    _buildClassItem("OS", "Operating System", "10:00 am",
                        Colors.green.shade400),
                    Divider(height: 1),
                    _buildClassItem("DS", "Data Structure", "11:00 am",
                        Colors.orange.shade400),
                    Divider(height: 1),
                    _buildClassItem(
                        "F", "Flutter", "12:00 pm", Colors.purple.shade400),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Other Options with enhanced styling
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12),
              _buildOptionItem("Check Attendance Report", Icons.bar_chart),
              _buildOptionItem("Faculty Details", Icons.people),
              _buildOptionItem("Class Details", Icons.class_),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassItem(
      String initial, String className, String time, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        className,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () {},
    );
  }

  Widget _buildOptionItem(String title, IconData icon) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue.shade700),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
