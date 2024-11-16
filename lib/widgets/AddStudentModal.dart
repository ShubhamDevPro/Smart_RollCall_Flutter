import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';

/// A modal widget that provides a form to add a new student to a specific batch
class AddStudentModal extends StatefulWidget {
  final String batchId;

  const AddStudentModal({super.key, required this.batchId});

  @override
  AddStudentModalState createState() => AddStudentModalState();
}

class AddStudentModalState extends State<AddStudentModal> {
  // Form key for validation and form control
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for managing text input fields
  final _nameController = TextEditingController();
  final _enrollNumberController = TextEditingController();
  
  // Service instance for Firestore operations
  final FirestoreService _firestoreService = FirestoreService();
  
  // Loading state flag for UI feedback
  bool _isLoading = false;

  /// Handles the addition of a new student to Firestore
  Future<void> _addStudent() async {
    // Dismiss keyboard first
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Add student data to Firestore with initial attendance status
        await _firestoreService.addStudent(
          widget.batchId,
          {
            'name': _nameController.text,
            'enrollNumber': _enrollNumberController.text,
            'isPresent': false, // Default attendance status
          },
        );
        if (!mounted) return;
        Navigator.pop(context); // Close modal on success
      } catch (e) {
        if (!mounted) return;
        // Show error message if addition fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding student: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Adjust padding to account for keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take minimum required space
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Student',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _enrollNumberController,
              decoration: const InputDecoration(
                labelText: 'Enrollment Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter enrollment number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _addStudent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Add Student'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Clean up controllers when the widget is disposed
  @override
  void dispose() {
    _nameController.dispose();
    _enrollNumberController.dispose();
    super.dispose();
  }
}