import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a student entity with their attendance status
class Student {
  // Basic student information
  final String name;
  final String enrollNumber;
  bool isPresent;

  /// Constructor to create a new Student instance
  /// [name] - Student's full name
  /// [enrollNumber] - Unique enrollment identifier
  /// [isPresent] - Attendance status, defaults to false
  Student({
    required this.name,
    required this.enrollNumber,
    this.isPresent = false,
  });

  /// Factory constructor to create a Student instance from Firestore document
  /// [doc] - Firestore DocumentSnapshot containing student data
  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Student(
      name: data['name'] ?? '', // Default to empty string if null
      enrollNumber: data['enrollNumber'] ?? '',
      isPresent: data['isPresent'] ?? false,
    );
  }

  /// Converts Student instance to a Map for Firestore storage
  /// Returns a Map with student properties as key-value pairs
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'enrollNumber': enrollNumber,
      'isPresent': isPresent,
    };
  }
}