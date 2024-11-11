import 'package:flutter/material.dart';

// A form widget that contains all course and batch input fields
class BatchFormFields extends StatelessWidget {
  // Controllers to manage the text input values
  final TextEditingController titleController;
  final TextEditingController batchNameController;
  final TextEditingController batchYearController;
  // Customizable UI parameters
  final double spacing;
  final double borderRadius;

  const BatchFormFields({
    super.key,
    required this.titleController,
    required this.batchNameController,
    required this.batchYearController,
    this.spacing = 16,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Course Title input field
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Course Title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            prefixIcon: const Icon(Icons.book),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        SizedBox(height: spacing),
        // Batch Name input field
        TextField(
          controller: batchNameController,
          decoration: InputDecoration(
            labelText: 'Batch Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            prefixIcon: const Icon(Icons.group),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        SizedBox(height: spacing),
        // Batch Year input field
        TextField(
          controller: batchYearController,
          decoration: InputDecoration(
            labelText: 'Batch Year',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
