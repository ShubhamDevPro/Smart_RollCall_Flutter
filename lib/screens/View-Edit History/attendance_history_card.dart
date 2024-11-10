import 'package:flutter/material.dart';

/// A customizable card widget that displays student attendance information
class AttendanceHistoryCard extends StatelessWidget {
  final String name;
  final String enrollNumber;
  final bool isPresent;
  final VoidCallback onStatusChanged;
  final int totalDays;
  final int presentDays;

  const AttendanceHistoryCard({
    required this.name,
    required this.enrollNumber,
    required this.isPresent,
    required this.onStatusChanged,
    this.totalDays = 0,
    this.presentDays = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attendancePercentage = totalDays > 0
        ? (presentDays / totalDays * 100).toStringAsFixed(1)
        : '0.0';

    /// Build a Material [Card] with rounded corners and elevation
    return Card(
      elevation: 2, // Add subtle shadow
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Spacing between cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: InkWell(
        /// Enable tap interaction with ripple effect
        onTap: onStatusChanged, // Trigger status change callback
        borderRadius: BorderRadius.circular(12), // Match card corners
        child: ListTile(
          /// Leading section shows attendance statistics
          leading: Row(
            mainAxisSize: MainAxisSize.min, // Take minimum required width
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // Vertically center
                crossAxisAlignment: CrossAxisAlignment.end, // Right align text
                children: [
                  /// Display attendance ratio (present/total days)
                  Text(
                    '$presentDays/$totalDays', // Format: "85/100"
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  /// Display attendance percentage
                  Text(
                    '$attendancePercentage%',
                    style: TextStyle(
                      fontSize: 12,
                      color: double.parse(attendancePercentage) >= 75
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8), // Spacing between stats and icon
              /// Present/Absent status indicator icon
              CircleAvatar(
                backgroundColor: isPresent
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Icon(
                  isPresent ? Icons.check : Icons.close,
                  color: isPresent ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          /// Main content shows student details
          title: Text(
            name, // Student's full name
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('Enrollment No: $enrollNumber'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPresent
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                    color: isPresent ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onStatusChanged,
                tooltip: 'Change attendance status',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
