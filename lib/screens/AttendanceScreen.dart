import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/models/student.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/widgets/AddStudentModal.dart';

class AttendanceScreen extends StatefulWidget {
  final String batchId;

  AttendanceScreen({required this.batchId});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    _firestoreService.getStudents(widget.batchId).listen((snapshot) {
      setState(() {
        students = snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
      });
    });
  }

  void _saveAttendance() {
    for (var student in students) {
      _firestoreService.updateStudentAttendance(widget.batchId, student.enrollNumber, student.isPresent);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance saved successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int presentCount = 0;

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  void _updateAttendance(bool isChecked) {
    setState(() {
      presentCount = students.where((student) => student.isPresent).length;
    });
  }

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
        title: const Text('Take Attendance', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearSelection,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Attendance',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Today\'s Attendance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${_getCurrentDate()})',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'Total',
                      '${students.length}',
                      Icons.groups_rounded,
                      Theme.of(context).primaryColor.withBlue(255),
                    ),
                    _buildStatCard(
                      'Present',
                      '$presentCount',
                      Icons.check_circle_rounded,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Absent',
                      '$absentCount',
                      Icons.cancel_rounded,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Students List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Chip(
                  label: Text(
                    '${presentCount}/${students.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return StudentCard(
                  student: students[index],
                  onChanged: _updateAttendance,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: presentCount > 0 ? _saveAttendance : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save_rounded),
                    SizedBox(width: 8),
                    Text(
                      'Save Attendance',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => AddStudentModal(batchId: widget.batchId),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: widget.student.isPresent 
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Text(
            widget.student.name[0],
            style: TextStyle(
              color: widget.student.isPresent ? Colors.green : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          widget.student.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Enrollment No: ${widget.student.enrollNumber}'),
        trailing: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: widget.student.isPresent,
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (bool? value) {
              setState(() {
                widget.student.isPresent = value ?? false;
              });
              widget.onChanged(widget.student.isPresent);
            },
          ),
        ),
      ),
    );
  }
}


