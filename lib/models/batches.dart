import 'package:flutter/material.dart';

class BatchFormFields extends StatelessWidget {
  final TextEditingController batchNameController;
  final TextEditingController batchYearController;
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
