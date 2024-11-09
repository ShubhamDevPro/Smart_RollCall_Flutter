import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/screens/AttendanceScreen.dart';
import 'package:smart_roll_call_flutter/screens/AttendanceHistory.dart';
import 'package:smart_roll_call_flutter/screens/CourseModal.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';

// Main widget for the home page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State class for MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  // List to store course data
  List<Map<String, dynamic>> courses = [];
  // Instance of FirestoreService to interact with Firestore
  final FirestoreService _firestoreService = FirestoreService();
  // Boolean to track loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load courses when the widget is initialized
    _loadCourses();
  }

  // Method to load courses from Firestore
  void _loadCourses() {
    setState(() => _isLoading = true); // Set loading state to true
    _firestoreService.getBatches().listen(
      (snapshot) {
        if (mounted) { // Check if the widget is still mounted
          setState(() {
            // Map Firestore documents to a list of course data
            courses = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'icon': IconData(data['icon'] ?? Icons.book.codePoint, fontFamily: 'MaterialIcons'),
                'title': data['title'] ?? 'Untitled',
                'batchName': data['batchName'] ?? '',
                'batchYear': data['batchYear'] ?? '',
                'batchId': doc.id,
              };
            }).toList();
            _isLoading = false; // Set loading state to false
          });
        }
      },
      onError: (error) {
        print('Error loading courses: $error');
        if (mounted) {
          setState(() {
            _isLoading = false; // Set loading state to false on error
          });
        }
      },
    );
  }

  // Method to add a new course
  Future<void> _addCourse() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseModal(
        onSave: (title, batchName, batchYear, iconData) async {
          try {
            setState(() => _isLoading = true); // Set loading state to true
            await _firestoreService.addBatch(batchName, batchYear, iconData, title);
            
            if (!mounted) return;
            Navigator.pop(context); // Dismiss the modal
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course created successfully')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating course: $e'),
                backgroundColor: Colors.red,
              ),
            );
          } finally {
            if (mounted) {
              setState(() => _isLoading = false); // Set loading state to false
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search delegate for courses
              showSearch(
                context: context,
                delegate: CourseSearchDelegate(courses: courses),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context), // Close the drawer
            ),
            // Add more drawer items as needed
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          // Handle navigation based on the selected index
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : courses.isEmpty
              ? const Center(child: Text('No courses added yet')) // Show message if no courses
              : ListView.builder(
                  itemCount: courses.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _buildCourseTile(
                      context: context,
                      icon: course['icon'],
                      title: course['title'],
                      batchName: course['batchName'],
                      batchYear: course['batchYear'],
                      index: index,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse, // Trigger add course method
        child: const Icon(Icons.add),
      ),
    );
  }

  // Method to build a course tile widget
  Widget _buildCourseTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String batchName,
    required String batchYear,
    required int index,
  }) {
    final key = Key(courses[index]['batchId'] ?? title); // Use batchId as key if available
    
    return Dismissible(
      key: key,
      confirmDismiss: (direction) async {
        // Show confirmation dialog before dismissing
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Course'),
              content: const Text('This course will be permanently deleted. This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancel deletion
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Confirm deletion
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        // Store the course data before removing it
        final deletedCourse = courses[index];

        try {
          // Delete from Firebase first
          await _firestoreService.deleteBatch(deletedCourse['batchId']);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course deleted successfully')),
            );
          }
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting course: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text('$batchName $batchYear'),
        onTap: () => _showCourseOptions(context, title, index), // Show course options
        onLongPress: () => _showEditCourseModal(context, courses[index], index), // Show edit modal
        trailing: IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.blue,
          ),
          onPressed: () => _showEditCourseModal(context, courses[index], index),
        ),
      ),
    );
  }

  // Method to show course options dialog
  void _showCourseOptions(BuildContext context, String courseTitle, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  courseTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceScreen(
                              batchId: courses[index]['batchId'],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'New Attendance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AttendanceHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, color: Colors.blue),
                      label: const Text(
                        'View/Edit History',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show edit course modal
  void _showEditCourseModal(BuildContext context, Map<String, dynamic> course, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CourseModal(
        initialTitle: course['title'],
        initialBatchName: course['batchName'],
        initialBatchYear: course['batchYear'],
        initialIcon: course['icon'],
        onSave: (title, batchName, batchYear, iconData) async {
          print('Attempting to update course with ID: ${course['batchId']}');
          print('Title: $title, BatchName: $batchName, BatchYear: $batchYear, Icon: ${iconData.codePoint}');
          try {
            await _firestoreService.updateBatch(
              course['batchId'],
              title,
              batchName,
              batchYear,
              iconData.codePoint,
            );
            setState(() {
              courses[index] = {
                'icon': iconData,
                'title': title,
                'batchName': batchName,
                'batchYear': batchYear,
                'batchId': course['batchId'],
              };
            });
            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course updated successfully')),
            );
          } catch (e) {
            print('Error updating course: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating course: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}

// Search delegate for searching courses
class CourseSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> courses;

  CourseSearchDelegate({required this.courses});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '', // Clear the search query
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null), // Close the search
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults(); // Build search results
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults(); // Build search suggestions
  }

  // Method to build search results
  Widget buildSearchResults() {
    final results = courses.where((course) =>
        course['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
        course['batchName'].toString().toLowerCase().contains(query.toLowerCase()) ||
        course['batchYear'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final course = results[index];
        return ListTile(
          leading: Icon(course['icon'] as IconData),
          title: Text(course['title']),
          subtitle: Text('${course['batchName']} ${course['batchYear']}'),
          onTap: () {
            close(context, course); // Close search with selected course
          },
        );
      },
    );
  }
}
