import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/screens/AttendanceScreen.dart';
import 'package:smart_roll_call_flutter/screens/View-Edit%20History/AttendanceHistory.dart';
import 'package:smart_roll_call_flutter/screens/CourseModal.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/screens/settings_screen.dart';
import 'package:smart_roll_call_flutter/screens/attendance_overview_screen.dart';

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
  // Add selected index for bottom nav
  int _selectedIndex = 0;
  
  // Add page controller
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method to handle bottom nav tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Method to load courses from Firestore
  void _loadCourses() {
    setState(() => _isLoading = true); // Set loading state to true
    _firestoreService.getBatches().listen(
      (snapshot) {
        if (mounted) {
          // Check if the widget is still mounted
          setState(() {
            // Map Firestore documents to a list of course data
            courses = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'icon': IconData(data['icon'] ?? Icons.book.codePoint,
                    fontFamily: 'MaterialIcons'),
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
            await _firestoreService.addBatch(
                batchName, batchYear, iconData, title);

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
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Smart Roll Call",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87, size: 28),
            onPressed: () => showSearch(
              context: context,
              delegate: CourseSearchDelegate(courses: courses),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: [
          // Home page (existing content)
          _buildHomePage(),
          
          // Attendance Overview page
          const AttendanceOverviewScreen(),
          
          // Settings page
          const SettingsScreen(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // Move existing home page content to a separate method
  Widget _buildHomePage() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Text(
                    "My Courses",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: courses.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return _buildCourseCard(
                              context: context,
                              icon: course['icon'],
                              title: course['title'],
                              batchName: course['batchName'],
                              batchYear: course['batchYear'],
                              index: index,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_courses.png', // Add an illustration
            height: 200,
          ),
          const SizedBox(height: 24),
          Text(
            'No Courses Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first course to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _addCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add Course',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String batchName,
    required String batchYear,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCourseOptions(context, title, index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$batchName $batchYear',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatsChip(
                              Icons.person_outline,
                              '32 Students',
                            ),
                            const SizedBox(width: 12),
                            _buildStatsChip(
                              Icons.calendar_today_outlined,
                              '12 Sessions',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditCourseModal(context, courses[index], index);
                        break;
                      case 'delete':
                        _confirmDelete(context, index);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: const Text(
            'This course will be permanently deleted. This action cannot be undone.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', 
                style: TextStyle(color: Colors.red)
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);
        // Delete the course from Firestore
        await _firestoreService.deleteBatch(courses[index]['batchId']);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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
                            builder: (context) => AttendanceHistoryScreen(
                              batchId: courses[index]['batchId'],
                            ),
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
  void _showEditCourseModal(
      BuildContext context, Map<String, dynamic> course, int index) {
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
          print(
              'Title: $title, BatchName: $batchName, BatchYear: $batchYear, Icon: ${iconData.codePoint}');
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
    final results = courses
        .where((course) =>
            course['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            course['batchName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            course['batchYear']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

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
