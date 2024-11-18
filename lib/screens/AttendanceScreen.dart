import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/models/student.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/widgets/AddStudentModal.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit History/AttendanceHistory.dart';
import 'package:flutter/services.dart';

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

  const AttendanceScreen({super.key, required this.batchId});

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

  // Add this to your state class
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Set up stream listener for student data from Firestore
    _firestoreService.getStudents(widget.batchId).listen((snapshot) {
      setState(() {
        students =
            snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
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
      final attendanceData = students
          .map((student) => {
                'name': student.name,
                'enrollNumber': student.enrollNumber,
                'isPresent': student.isPresent,
              })
          .toList();

      // Save attendance data for current date
      await _firestoreService.saveAttendanceForDate(
        widget.batchId,
        selectedDate,
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
    return '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
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

  // Add this method to handle date selection
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Add logic here to load attendance for selected date
    }
  }

  @override
  Widget build(BuildContext context) {
    final absentCount = students.length - presentCount;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Take Attendance',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          elevation: 0,
          backgroundColor: theme.primaryColor,
          actions: [
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
              ),
              tooltip: 'Reset Attendance',
            ),
            const SizedBox(width: 8),
          ],
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Date selection container - now full width
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedDate.day == DateTime.now().day &&
                                        selectedDate.month ==
                                            DateTime.now().month &&
                                        selectedDate.year == DateTime.now().year
                                    ? 'Today\'s Attendance'
                                    : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Statistics cards - now in a Row with equal spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildStatCard(
                                'Total',
                                '${students.length}',
                                Icons.groups_rounded,
                                Theme.of(context).primaryColor.withBlue(255),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildStatCard(
                                'Present',
                                '$presentCount',
                                Icons.check_circle_rounded,
                                Colors.green,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildStatCard(
                                'Absent',
                                '${students.length - presentCount}',
                                Icons.cancel_rounded,
                                Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Updated search field styling
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or enrollment number',
                      prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon:
                                  Icon(Icons.clear, color: theme.primaryColor),
                              onPressed: () {
                                _searchController.clear();
                                _filterStudents('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: theme.primaryColor.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: theme.primaryColor.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: theme.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                    onChanged: _filterStudents,
                  ),
                ),
                // Updated students list header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Students List',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: students.isEmpty ? null : _toggleSelectAll,
                        icon: Icon(
                          presentCount == students.length
                              ? Icons.deselect
                              : Icons.select_all,
                          size: 20,
                        ),
                        label: Text(
                          presentCount == students.length
                              ? 'Deselect All'
                              : 'Select All',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$presentCount/${students.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Students list
                SizedBox(
                  height: MediaQuery.of(context).size.height - 400,
                  child: Column(
                    children: [
                      // Make the ListView take remaining space
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (presentCount > 0)
              FloatingActionButton.extended(
                onPressed: _saveAttendance,
                label: const Text('Save Attendance'),
                icon: const Icon(Icons.save_rounded),
                heroTag: 'save',
              ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) =>
                      AddStudentModal(batchId: widget.batchId),
                );
              },
              heroTag: 'add',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a statistics card widget with specified title, value, icon, and color
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
    );
  }
}

/// StudentCard widget displays individual student information and attendance status
/// It shows the student's name, enrollment number, and a checkbox to mark attendance
class StudentCard extends StatefulWidget {
  final Student student;
  final ValueChanged<bool> onChanged;

  const StudentCard(
      {super.key, required this.student, required this.onChanged});

  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Text(
            widget.student.name[0],
            style: TextStyle(
              color: widget.student.isPresent
                  ? Theme.of(context).primaryColor
                  : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          widget.student.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Text(
          'Enrollment No: ${widget.student.enrollNumber}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        trailing: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: widget.student.isPresent,
            activeColor: Theme.of(context).primaryColor,
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
