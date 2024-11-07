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
        title: Text("Courses"),
        leading: Icon(Icons.menu),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {}, // No action needed for now
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {}, // No action needed for now
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {}, // No action needed for now
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildCourseTile(
            icon: Icons.calculate,
            title: 'Control Systems ARI312',
            subtitle: 'IIoT 2023-2027',
          ),
          _buildCourseTile(
            icon: Icons.edit,
            title: 'Artificial Intelligence ARI314',
            subtitle: 'IIoT 2022-2026',
          ),
          _buildCourseTile(
            icon: Icons.send,
            title: 'Digital Electronics ARD',
            subtitle: 'A Basic Guide to Build Data Driven Mob...',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // No action needed for now
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Currently selected index
        onTap: (index) {}, // No action needed for now
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {}, // No action needed for now
    );
  }
}