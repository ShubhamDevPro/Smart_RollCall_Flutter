// File: AttendanceHistory.dart
// Purpose: Displays and manages attendance history for a batch of students
// Features: Date selection, search, attendance status updates, and Excel export

import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit History/attendance_history_card.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit History/attendance_summary_card.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit History/excel_export.dart';

/// Screen widget that displays attendance history for a specific batch
/// Allows viewing and editing attendance records for different dates
class AttendanceHistoryScreen extends StatefulWidget {
  // Unique identifier for the batch whose attendance is being displayed
  final String? batchId;

  const AttendanceHistoryScreen({Key? key, this.batchId}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  // Service instance to interact with Firestore database
  final FirestoreService _firestoreService = FirestoreService();
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // Currently selected date for attendance viewing
  DateTime selectedDate = DateTime.now();
  // List to store all attendance records
  List<Map<String, dynamic>> attendanceData = [];
  // List to store filtered attendance records based on search
  List<Map<String, dynamic>> filteredAttendanceData = [];
  // Loading state flag
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load attendance data when screen initializes
    _loadAttendanceData();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _searchController.dispose();
    super.dispose();
  }

  /// Filters the attendance list based on search query
  /// Matches student name or enrollment number
  void _filterAttendance(String query) {
    setState(() {
      if (query.isEmpty) {
        // If search is empty, show all records
        filteredAttendanceData = attendanceData;
      } else {
        // Filter based on name or enrollment number
        filteredAttendanceData = attendanceData.where((student) {
          final nameLower = student['name'].toString().toLowerCase();
          final enrollLower = student['enrollNumber'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return nameLower.contains(searchLower) ||
              enrollLower.contains(searchLower);
        }).toList();
      }
    });
  }

  /// Fetches attendance data from Firestore for the selected date
  Future<void> _loadAttendanceData() async {
    setState(() => isLoading = true);

    try {
      // Get attendance records for all students on selected date
      final data = await _firestoreService.getAttendanceForDateAll(
        selectedDate,
        widget.batchId,
      );
      setState(() {
        attendanceData = data;
        filteredAttendanceData = data;
      });
    } catch (e) {
      if (!mounted) return;
      // Show error message if data loading fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Updates attendance status for a student
  /// Toggles between present and absent
  Future<void> _updateAttendanceStatus(Map<String, dynamic> student) async {
    setState(() => isLoading = true);

    try {
      // Toggle the attendance status
      final newStatus = !student['isPresent'];
      await _firestoreService.updateAttendanceStatus(
        student['batchId'],
        student['enrollNumber'],
        selectedDate,
        newStatus,
      );
      // Reload data to reflect changes
      await _loadAttendanceData();

      if (!mounted) return;
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Show error message if update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating attendance: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Exports attendance data to Excel file
  Future<void> _exportAttendanceData() async {
    setState(() => isLoading = true);

    await ExcelExportUtil.exportAttendanceData(
      data: attendanceData,
      selectedDate: selectedDate,
      onError: (error) {
        // Show error message if export fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onSuccess: () {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance data exported successfully'),
          ),
        );
      },
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          // Export button in app bar
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAttendanceData,
            tooltip: 'Export Attendance Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selection and search section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Date navigation row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous day button
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          selectedDate =
                              selectedDate.subtract(const Duration(days: 1));
                          _loadAttendanceData();
                        });
                      },
                    ),
                    // Date picker button
                    TextButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                            _loadAttendanceData();
                          });
                        }
                      },
                      child: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    // Next day button (disabled if date is today)
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: selectedDate.isBefore(DateTime.now())
                          ? () {
                              setState(() {
                                selectedDate =
                                    selectedDate.add(const Duration(days: 1));
                                _loadAttendanceData();
                              });
                            }
                          : null,
                    ),
                  ],
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or enrollment number',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterAttendance('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _filterAttendance,
                  ),
                ),
              ],
            ),
          ),

          // Attendance summary cards section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Total students card
                AttendanceSummaryCard(
                  title: 'Total',
                  count: filteredAttendanceData.length.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                // Present students card
                AttendanceSummaryCard(
                  title: 'Present',
                  count: filteredAttendanceData
                      .where((s) => s['isPresent'])
                      .length
                      .toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                // Absent students card
                AttendanceSummaryCard(
                  title: 'Absent',
                  count: filteredAttendanceData
                      .where((s) => !s['isPresent'])
                      .length
                      .toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // Attendance list section
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAttendanceData.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No attendance records for this date'
                              : 'No students found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAttendanceData.length,
                        itemBuilder: (context, index) {
                          final student = filteredAttendanceData[index];
                          return AttendanceHistoryCard(
                            name: student['name'],
                            enrollNumber: student['enrollNumber'],
                            isPresent: student['isPresent'],
                            onStatusChanged: () =>
                                _updateAttendanceStatus(student),
                            totalDays: student['totalDays'] ?? 0,
                            presentDays: student['presentDays'] ?? 0,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
