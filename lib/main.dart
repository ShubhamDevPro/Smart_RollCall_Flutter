import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/screens/AttendanceScreen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AttendanceScreen(),
    );
  }
}

