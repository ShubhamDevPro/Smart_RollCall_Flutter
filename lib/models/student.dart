import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String name;
  final String enrollNumber;
  bool isPresent;

  Student({
    required this.name,
    required this.enrollNumber,
    this.isPresent = false,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Student(
      name: data['name'] ?? '',
      enrollNumber: data['enrollNumber'] ?? '',
      isPresent: data['isPresent'] ?? false,
    );
  }
}