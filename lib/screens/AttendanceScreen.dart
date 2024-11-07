import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/models/student.dart';
class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<Student> students = [
    Student(name: 'Shubham Dev', rollNumber: '001'),
    Student(name: 'Karan Bhatia', rollNumber: '002'),
    Student(name: 'Chaitanya Gupta', rollNumber: '003'),
    Student(name: 'Deepak Kumar', rollNumber: '004'),
    Student(name: 'Avani Jain', rollNumber: '005'),
    Student(name: 'Naveen Sharma', rollNumber: '006'),
    Student(name: 'Harsh Thakur', rollNumber: '007'),
    Student(name: 'Vasudev Sharma', rollNumber: '008'),
    Student(name: 'Ayush Vishwakarma', rollNumber: '009'),
    Student(name: 'Dhruv Srivastava', rollNumber: '010'),
    Student(name: 'Shashikant Sharma', rollNumber: '011'),
  ];

  int presentCount = 0;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        actions: [
          TextButton(
            onPressed: _clearSelection,
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Students: ${students.length}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Present: $presentCount',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Empty function
              },
              child: Text('Save'),
            ),
          ),
        ],
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
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(widget.student.name),
        subtitle: Text('Roll No: ${widget.student.rollNumber}'),
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


