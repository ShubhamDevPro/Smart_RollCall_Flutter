import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/widgets/batches.dart';

// A modal widget that handles both creating and editing course information
class CourseModal extends StatefulWidget {
  // Callback function that will be called when saving the course
  // Takes course details as parameters and handles the save operation
  final Function(
          String title, String batchName, String batchYear, IconData iconData)
      onSave;

  // Optional initial values for editing an existing course
  final String? initialTitle;
  final String? initialBatchName;
  final String? initialBatchYear;
  final IconData? initialIcon;

  const CourseModal({
    super.key,
    required this.onSave,
    this.initialTitle,
    this.initialBatchName,
    this.initialBatchYear,
    this.initialIcon,
  });

  @override
  State<CourseModal> createState() => _CourseModalState();
}

class _CourseModalState extends State<CourseModal> {
  // Text controllers initialized with initial values if editing, or empty if creating new
  late final titleController = TextEditingController(text: widget.initialTitle);
  late final batchNameController =
      TextEditingController(text: widget.initialBatchName);
  late final batchYearController =
      TextEditingController(text: widget.initialBatchYear);

  // Tracks whether the course is Theory or Practical based on the icon
  late String selectedCourseType = _getCourseTypeFromIcon(widget.initialIcon);
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  widget.initialTitle == null
                      ? 'Add New Course'
                      : 'Edit Course',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Course type selector
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Icon(
                    selectedCourseType == 'Practical' ? Icons.build : Icons.book,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _showCourseTypePicker(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Change Course Type'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Form fields
            BatchFormFields(
              titleController: titleController,
              batchNameController: batchNameController,
              batchYearController: batchYearController,
            ),
            const SizedBox(height: 24),
            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _validateAndSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.initialTitle == null ? 'Create Course' : 'Update Course',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Validates form inputs and calls the onSave callback
  void _validateAndSave() async {
    // Basic validation
    if (titleController.text.isEmpty ||
        batchNameController.text.isEmpty ||
        batchYearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the onSave callback with the current values
      await widget.onSave(
        titleController.text,
        batchNameController.text,
        batchYearController.text,
        _getIconData(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Shows a dialog to select course type (Theory/Practical)
  void _showCourseTypePicker(BuildContext context) {
    final List<String> courseTypes = ['Theory', 'Practical'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Course Type'),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: courseTypes
                .map((type) => _buildCourseTypeOption(type))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Helper method to convert icon to course type string
  String _getCourseTypeFromIcon(IconData? icon) {
    return icon == Icons.build ? 'Practical' : 'Theory';
  }

  // Helper method to convert course type string to corresponding icon
  IconData _getIconFromCourseType(String type) {
    return type == 'Practical' ? Icons.build : Icons.book;
  }

  Widget _buildCourseTypeOption(String type) {
    final isSelected = selectedCourseType == type;
    return ListTile(
      leading: Icon(
        type == 'Practical' ? Icons.build : Icons.book,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        type,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      dense: true, // Makes the ListTile more compact
      onTap: () {
        setState(() => selectedCourseType = type);
        Navigator.pop(context);
      },
    );
  }

  // Add this method to get the appropriate IconData
  IconData _getIconData() {
    return selectedCourseType == 'Practical' ? Icons.build : Icons.book;
  }

  @override
  void dispose() {
    titleController.dispose();
    batchNameController.dispose();
    batchYearController.dispose();
    super.dispose();
  }
}
