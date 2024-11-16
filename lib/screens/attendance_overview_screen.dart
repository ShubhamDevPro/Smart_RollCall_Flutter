import 'package:flutter/material.dart';

class AttendanceOverviewScreen extends StatelessWidget {
  const AttendanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Text(
          'Attendance Overview',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 