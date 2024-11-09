import 'package:flutter/material.dart';

// A form widget that contains input fields for batch information
class BatchFormFields extends StatelessWidget {
  // Controllers to manage the text input values
  final TextEditingController batchNameController;
  final TextEditingController batchYearController;
  // Customizable UI parameters
  final double spacing;
  final double borderRadius;

  const BatchFormFields({
    super.key,
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
        // Batch Name input field
        TextField(
          controller: batchNameController,
          decoration: InputDecoration(
            labelText: 'Batch Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            prefixIcon: const Icon(Icons.group), // Group icon to indicate batch
          ),
          textCapitalization: TextCapitalization.words, // Capitalize each word
        ),
        // Vertical spacing between fields
        SizedBox(height: spacing),
        // Batch Year input field
        TextField(
          controller: batchYearController,
          decoration: InputDecoration(
            labelText: 'Batch Year',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            prefixIcon: const Icon(Icons.calendar_today), // Calendar icon for year
          ),
          keyboardType: TextInputType.number, // Show numeric keyboard
        ),
      ],
    );
  }
}
