import 'package:flutter/material.dart';

/// Screen widget to display and manage attendance history
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  // Tracks the currently selected date for attendance viewing
  DateTime selectedDate = DateTime.now();

  /// Shows a date picker dialog and updates the selected date
  /// [context] - BuildContext for showing the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Can't select future dates
      builder: (context, child) {
        // Customize the date picker theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    // Update state if a new date was selected
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _loadAttendanceData();
      });
    }
  }

  /// Loads attendance data for the selected date
  /// Shows error message if no attendance exists for today
  void _loadAttendanceData() {
    // TODO: Load attendance data for selected date
    // If no data exists for today, show error
    // If data exists, show attendance list with edit capability
    bool attendanceExists = false; // Replace with actual check

    // Check if selected date is today and no attendance exists
    if (!attendanceExists && selectedDate.isAtSameMomentAs(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No attendance marked for today'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          // Calendar icon button for quick date selection
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selection header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display selected date
                Text(
                  'Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Button to change date
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Change Date'),
                ),
              ],
            ),
          ),
          // Attendance list or placeholder
          Expanded(
            child: Center(
              // TODO: Replace with actual attendance list widget
              child: Text(
                'No attendance data available for selected date',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 