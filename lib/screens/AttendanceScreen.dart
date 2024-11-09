import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/models/student.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/widgets/AddStudentModal.dart';

/// Screen widget for managing daily attendance
class AttendanceScreen extends StatefulWidget {
  final String batchId;

  AttendanceScreen({required this.batchId});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Student> students = [];
  int presentCount = 0;

  @override
  void initState() {
    super.initState();
    // Listen to real-time updates of student data from Firestore
    _firestoreService.getStudents(widget.batchId).listen((snapshot) {
      setState(() {
        students = snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
      });
    });
  }

  /// Saves attendance status for all students to Firestore
  void _saveAttendance() {
    for (var student in students) {
      _firestoreService.updateStudentAttendance(
        widget.batchId, 
        student.enrollNumber, 
        student.isPresent
      );
    }
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully!')),
    );
  }

  /// Returns formatted current date string (DD/MM/YYYY)
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  /// Updates the count of present students when attendance is modified
  void _updateAttendance(bool isChecked) {
    setState(() {
      presentCount = students.where((student) => student.isPresent).length;
    });
  }

  /// Resets attendance status for all students to absent
  void _clearSelection() {
    setState(() {
      for (var student in students) {
        student.isPresent = false;
      }
      presentCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final absentCount = students.length - presentCount;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        actions: [
          // Reset button to clear all attendance
          IconButton(
            onPressed: _clearSelection,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Attendance',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section with attendance statistics
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8)
                ],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                // Date display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Today\'s Attendance'),
                    Text('(${_getCurrentDate()})'),
                  ],
                ),
                // Statistics cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Total', '${students.length}', Icons.groups_rounded),
                    _buildStatCard('Present', '$presentCount', Icons.check_circle_rounded),
                    _buildStatCard('Absent', '$absentCount', Icons.cancel_rounded),
                  ],
                ),
              ],
            ),
          ),

          // Students list header with count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Students List'),
                Chip(label: Text('${presentCount}/${students.length}')),
              ],
            ),
          ),

          // Scrollable list of student cards
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return StudentCard(
                  student: students[index],
                  onChanged: _updateAttendance,
                );
              },
            ),
          ),

          // Save attendance button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: presentCount > 0 ? _saveAttendance : null,
                child: const Text('Save Attendance'),
              ),
            ),
          ),
        ],
      ),
      // FAB to add new students
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => AddStudentModal(batchId: widget.batchId),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds a statistics card with title, value, and icon
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Icon(icon),
            Text(value),
            Text(title),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying individual student attendance cards
class StudentCard extends StatefulWidget {
  final Student student;
  final ValueChanged<bool> onChanged;

  StudentCard({required this.student, required this.onChanged});

  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // Student avatar with first letter of name
        leading: CircleAvatar(
          child: Text(widget.student.name[0]),
        ),
        title: Text(widget.student.name),
        subtitle: Text('Enrollment No: ${widget.student.enrollNumber}'),
        // Attendance checkbox
        trailing: Checkbox(
          value: widget.student.isPresent,
          onChanged: (bool? value) {
            setState(() {
              widget.student.isPresent = value ?? false;
            });
            widget.onChanged(widget.student.isPresent);
          },
        ),
      ),
    );
  }
}


