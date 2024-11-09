import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/screens/AttendanceScreen.dart';
import 'package:smart_roll_call_flutter/screens/CourseModal.dart';

/// A StatefulWidget that displays a list of batches/courses
/// with swipe-to-delete functionality and navigation to attendance screen
class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});
  
  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  // Instance of FirestoreService to handle database operations
  final FirestoreService _firestoreService = FirestoreService();
  
  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to real-time updates from Firestore
    return StreamBuilder<QuerySnapshot>(
      // Get stream of batches from Firestore
      stream: _firestoreService.getBatches(),
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Show loading indicator while data is being fetched
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Build list of batch cards
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Dismissible widget enables swipe-to-delete functionality
            return Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.endToStart, // Only allow right to left swipe
              
              // Show confirmation dialog before deletion
              confirmDismiss: (direction) => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Course'),
                  content: const Text('Are you sure you want to delete this course?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              
              // Handle batch deletion when confirmed
              onDismissed: (direction) async {
                try {
                  await _firestoreService.deleteBatch(doc.id);
                  // Show success message if deletion successful
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Course deleted successfully')),
                  );
                } catch (e) {
                  // Show error message if deletion fails
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting course: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              
              // Red background with delete icon shown during swipe
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              
              // Card widget displaying batch information
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  // Display batch title with bold style
                  title: Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Display batch name and year in grey color
                  subtitle: Text(
                    '${data['batchName'] ?? ''} ${data['batchYear'] ?? ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  // Display circular avatar with batch icon
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      IconData(data['icon'] ?? Icons.book.codePoint,
                        fontFamily: 'MaterialIcons'
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  // Navigate to AttendanceScreen when tapped
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceScreen(batchId: doc.id),
                    ),
                  ),
                  onLongPress: () => _showEditCourseModal(context, doc),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showEditCourseModal(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CourseModal(
        initialTitle: data['title'],
        initialBatchName: data['batchName'],
        initialBatchYear: data['batchYear'],
        initialIcon: IconData(
          data['icon'] ?? Icons.book.codePoint,
          fontFamily: 'MaterialIcons',
        ),
        onSave: (title, batchName, batchYear, iconData) async {
          try {
            await _firestoreService.updateBatch(
              doc.id,
              title,
              batchName,
              batchYear,
              iconData.codePoint,
            );
            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course updated successfully')),
            );
          } catch (e) {
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