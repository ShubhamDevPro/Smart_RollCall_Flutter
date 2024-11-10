import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const AttendanceSummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
