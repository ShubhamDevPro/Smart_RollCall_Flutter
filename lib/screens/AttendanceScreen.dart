import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/models/student.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/widgets/AddStudentModal.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit History/AttendanceHistory.dart';

/// AttendanceScreen is a stateful widget that manages the attendance marking interface
/// for a specific batch of students.
///
/// It provides functionality to:
/// - Display all students in a batch
/// - Mark attendance with checkboxes
/// - Search/filter students
/// - View attendance statistics
/// - Save attendance records to Firestore
class AttendanceScreen extends StatefulWidget {
  final String batchId;

  AttendanceScreen({required this.batchId});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Service instance to handle Firestore operations
  final FirestoreService _firestoreService = FirestoreService();
  
  // Lists to manage all students and filtered students for search
  List<Student> students = [];
  List<Student> filteredStudents = [];
  
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set up stream listener for student data from Firestore
    _firestoreService.getStudents(widget.batchId).listen((snapshot) {
      setState(() {
        students = snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
        filteredStudents = students;
      });
    });
  }

  /// Filters the student list based on search query
  /// Matches against both student name and enrollment number
  void _filterStudents(String query) {
    setState(() {
      filteredStudents = students.where((student) {
        final nameLower = student.name.toLowerCase();
        final enrollLower = student.enrollNumber.toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower) ||
              enrollLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  void dispose() {
    // Clean up text controller when widget is disposed
    _searchController.dispose();
    super.dispose();
  }

  /// Saves the current attendance state to Firestore
  /// Shows success/error messages and navigates to history screen on success
  void _saveAttendance() async {
    // Ensure keyboard is dismissed before proceeding
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      // Prepare attendance data for storage
      final attendanceData = students.map((student) => {
        'name': student.name,
        'enrollNumber': student.enrollNumber,
        'isPresent': student.isPresent,
      }).toList();

      // Save attendance data for current date
      await _firestoreService.saveAttendanceForDate(
        widget.batchId,
        DateTime.now(),
        attendanceData,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to attendance history screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceHistoryScreen(
            batchId: widget.batchId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Show error message if save fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving attendance: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Track number of present students
  int presentCount = 0;

  /// Returns current date in DD/MM/YYYY format
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  /// Updates the present count when attendance is marked
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

  /// Toggles attendance status for all students
  /// If all are present, marks all absent; if any are absent, marks all present
  void _toggleSelectAll() {
    setState(() {
      bool allSelected = presentCount == students.length;
      for (var student in students) {
        student.isPresent = !allSelected;
      }
      presentCount = allSelected ? 0 : students.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final absentCount = students.length - presentCount;
    
    return GestureDetector(
      // Dismiss keyboard when tapping outside input fields
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Take Attendance', style: TextStyle(fontWeight: FontWeight.w600)),
          elevation: 0,
          actions: [
            // Reset button in app bar
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
            // Header section with gradient background
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
                  // Date display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Today\'s Attendance',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  // Statistics cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Total students card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildStatCard(
                            'Total',
                            '${students.length}',
                            Icons.groups_rounded,
                            Theme.of(context).primaryColor.withBlue(255),
                          ),
                        ),
                        // Present students card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildStatCard(
                            'Present',
                            '$presentCount',
                            Icons.check_circle_rounded,
                            Colors.green,
                          ),
                        ),
                        // Absent students card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildStatCard(
                            'Absent',
                            '$absentCount',
                            Icons.cancel_rounded,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                            _filterStudents('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: _filterStudents,
              ),
            ),
            // Students list header with controls
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Students List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Select/Deselect all button
                  TextButton.icon(
                    onPressed: students.isEmpty ? null : _toggleSelectAll,
                    icon: Icon(
                      presentCount == students.length ? Icons.deselect : Icons.select_all,
                      size: 20,
                    ),
                    label: Text(
                      presentCount == students.length ? 'Deselect All' : 'Select All',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Attendance count chip
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
            // Students list
            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        'No students found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        return StudentCard(
                          student: filteredStudents[index],
                          onChanged: _updateAttendance,
                        );
                      },
                    ),
            ),
            // Save button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: presentCount > 0 ? _saveAttendance : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save_rounded),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Save Attendance',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Add student floating action button
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
      ),
    );
  }

  /// Builds a statistics card widget with specified title, value, icon, and color
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 100,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// StudentCard widget displays individual student information and attendance status
/// It shows the student's name, enrollment number, and a checkbox to mark attendance
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
        // Avatar showing first letter of student's name with dynamic color based on attendance
        leading: CircleAvatar(
          backgroundColor: widget.student.isPresent 
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Text(
            widget.student.name[0],  // Display first letter of student's name
            style: TextStyle(
              color: widget.student.isPresent ? Colors.green : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Student name display
        title: Text(
          widget.student.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        // Enrollment number display
        subtitle: Text('Enrollment No: ${widget.student.enrollNumber}'),
        // Attendance checkbox with custom styling
        trailing: Transform.scale(
          scale: 1.2,  // Make checkbox slightly larger
          child: Checkbox(
            value: widget.student.isPresent,
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            // Update attendance status and trigger callback when checkbox is toggled
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