import 'package:flutter/material.dart';
class AttendanceScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return StudentCard(student: students[index]);
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

  StudentCard({required this.student});

  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(widget.student.name),
        subtitle: Text('Roll No: ${widget.student.rollNumber}'),
        trailing: Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
        ),
      ),
    );
  }
}

class Student {
  final String name;
  final String rollNumber;

  Student({required this.name, required this.rollNumber});
}