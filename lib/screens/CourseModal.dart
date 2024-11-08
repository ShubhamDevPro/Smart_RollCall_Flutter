import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/models/batches.dart';

class CourseModal extends StatefulWidget {
  final Function(
          String title, String batchName, String batchYear, IconData iconData)
      onSave;
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
  late final titleController = TextEditingController(text: widget.initialTitle);
  late final batchNameController =
      TextEditingController(text: widget.initialBatchName);
  late final batchYearController =
      TextEditingController(text: widget.initialBatchYear);
  late IconData selectedIcon = widget.initialIcon ?? Icons.book;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  widget.initialTitle == null ? 'Add New Course' : 'Edit Course',
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
            // Icon selector
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Icon(selectedIcon, size: 30),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _showIconPicker(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Change Icon'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Course Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.book),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            BatchFormFields(
              batchNameController: batchNameController,
              batchYearController: batchYearController,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _validateAndSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.initialTitle == null ? 'Create Course' : 'Update Course',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndSave() {
    // Validate all fields
    final String title = titleController.text.trim();
    final String batchName = batchNameController.text.trim();
    final String batchYear = batchYearController.text.trim();

    if (title.isEmpty || batchName.isEmpty || batchYear.isEmpty) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onSave(title, batchName, batchYear, selectedIcon);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showIconPicker(BuildContext context) {
    final List<IconData> icons = [
      Icons.build, // wrench/tool icon
      Icons.book, // book icon
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: icons.map((icon) => _buildIconOption(icon)).toList(),
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

  Widget _buildIconOption(IconData icon) {
    final isSelected = selectedIcon == icon;
    return InkWell(
      onTap: () {
        setState(() => selectedIcon = icon);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 30,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
    );
  }
}
