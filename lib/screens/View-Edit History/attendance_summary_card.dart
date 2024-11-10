import 'package:flutter/material.dart';

/// A card widget that displays a summary metric for attendance data.
///
/// This widget creates a vertical card layout with:
/// - An icon representing the metric type
/// - A count/value display
/// - A descriptive title
///
/// Example usage:
/// ```dart
/// AttendanceSummaryCard(
///   title: 'Present Today',
///   count: '42',
///   icon: Icons.person,
///   color: Colors.green,
/// )
/// ```
class AttendanceSummaryCard extends StatelessWidget {
  /// The descriptive text shown below the count
  /// Example: "Present", "Absent", "Total Students"
  final String title;

  /// The numeric value or metric to display
  /// Can be a number or percentage
  final String count;

  /// The icon shown at the top of the card
  /// Should visually represent the metric type
  final IconData icon;

  /// The theme color used for both icon and count
  /// Should provide good contrast and visual meaning
  final Color color;

  /// Creates an attendance summary metric card.
  ///
  /// All parameters are required:
  /// - [title]: The metric description
  /// - [count]: The value to display
  /// - [icon]: The representing icon
  /// - [color]: Theme color for icon and count
  const AttendanceSummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Create a Material card with elevation and rounded corners
    return Card(
      elevation: 2, // Subtle shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Consistent corner radius
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, // Horizontal padding for content
          vertical: 12,   // Vertical padding for content
        ),
        /// Vertical layout for icon, count and title
        child: Column(
          children: [
            /// Top icon with theme color
            Icon(icon, color: color),
            const SizedBox(height: 4), // Spacing between icon and count
            /// Large count display with theme color
            Text(
              count,
              style: TextStyle(
                fontSize: 20,          // Large size for emphasis
                fontWeight: FontWeight.bold,
                color: color,          // Match icon color
              ),
            ),
            /// Bottom title text in gray
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600], // Subdued color for secondary text
                fontSize: 12,            // Smaller size for description
              ),
            ),
          ],
        ),
      ),
    );
  }
}