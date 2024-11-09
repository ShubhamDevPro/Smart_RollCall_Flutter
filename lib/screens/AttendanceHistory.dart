import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';

/// Screen widget to display and manage attendance history
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> attendanceData = [];
  List<Map<String, dynamic>> filteredAttendanceData = [];
  bool isLoading = false;
  
  // Add text controller for search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  // Add search method
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
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _firestoreService.getAttendanceForDateAll(selectedDate);
      setState(() {
        attendanceData = data;
        filteredAttendanceData = data; // Update filtered data too
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance: $e')),
      );
    }
  }

  /// Updates the attendance status for a student
  Future<void> _updateAttendanceStatus(Map<String, dynamic> student) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Toggle the attendance status
      final newStatus = !student['isPresent'];
      
      await _firestoreService.updateAttendanceStatus(
        student['batchId'],
        student['enrollNumber'],
        selectedDate,
        newStatus,
      );

      // Refresh the attendance data
      await _loadAttendanceData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
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
                          selectedDate = selectedDate.subtract(const Duration(days: 1));
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
                      onPressed: selectedDate.isBefore(DateTime.now()) ? () {
                        setState(() {
                          selectedDate = selectedDate.add(const Duration(days: 1));
                          _loadAttendanceData();
                        });
                      } : null,
                    ),
                  ],
                ),
                // Add Search TextField
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
                _buildSummaryCard(
                  'Total',
                  filteredAttendanceData.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  'Present',
                  filteredAttendanceData.where((s) => s['isPresent']).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Absent',
                  filteredAttendanceData.where((s) => !s['isPresent']).length.toString(),
                  Icons.cancel,
                  Colors.red,
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
                            onStatusChanged: () => _updateAttendanceStatus(student),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color color) {
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

// New widget for displaying attendance history cards
class AttendanceHistoryCard extends StatelessWidget {
  final String name;
  final String enrollNumber;
  final bool isPresent;
  final VoidCallback onStatusChanged;

  const AttendanceHistoryCard({
    required this.name,
    required this.enrollNumber,
    required this.isPresent,
    required this.onStatusChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onStatusChanged, // Make the entire card tappable
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isPresent 
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
              isPresent ? Icons.check : Icons.close,
              color: isPresent ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('Enrollment No: $enrollNumber'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
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