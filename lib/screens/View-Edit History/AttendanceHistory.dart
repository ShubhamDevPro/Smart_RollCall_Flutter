import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit History/attendance_history_card.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit History/attendance_summary_card.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit History/excel_export.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String? batchId;

  const AttendanceHistoryScreen({Key? key, this.batchId}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> attendanceData = [];
  List<Map<String, dynamic>> filteredAttendanceData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAttendance(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAttendanceData = attendanceData;
      } else {
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

  Future<void> _loadAttendanceData() async {
    setState(() => isLoading = true);

    try {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateAttendanceStatus(Map<String, dynamic> student) async {
    setState(() => isLoading = true);

    try {
      final newStatus = !student['isPresent'];
      await _firestoreService.updateAttendanceStatus(
        student['batchId'],
        student['enrollNumber'],
        selectedDate,
        newStatus,
      );
      await _loadAttendanceData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
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

  Future<void> _exportAttendanceData() async {
    setState(() => isLoading = true);

    await ExcelExportUtil.exportAttendanceData(
      data: attendanceData,
      selectedDate: selectedDate,
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onSuccess: () {
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
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAttendanceData,
            tooltip: 'Export Attendance Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

          // Attendance Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AttendanceSummaryCard(
                  title: 'Total',
                  count: filteredAttendanceData.length.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                AttendanceSummaryCard(
                  title: 'Present',
                  count: filteredAttendanceData
                      .where((s) => s['isPresent'])
                      .length
                      .toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
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

          // Attendance List
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
