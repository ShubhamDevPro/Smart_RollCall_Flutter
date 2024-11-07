import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/models/student.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Using a fixed userId for public access
  final String userId = 'public_user';

  // Get batches for current user
  Stream<QuerySnapshot> getBatches() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('batches')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add new batch
  Future<void> addBatch(String name, String year, IconData icon, String title) {
    return _firestore.collection('users').doc(userId).collection('batches').add({
      'name': name,
      'year': year,
      'icon': icon.codePoint,
      'title': title,
      'createdAt': Timestamp.now(),
    });
  }

  // Get students in a batch
  Stream<QuerySnapshot> getStudents(String batchId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('batches')
        .doc(batchId)
        .collection('students')
        .snapshots();
  }

  // Add student to batch
  Future<void> addStudent(String batchId, Student student) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('batches')
        .doc(batchId)
        .collection('students')
        .add({
      'name': student.name,
      'enrollNumber': student.enrollNumber,
      'isPresent': student.isPresent,
    });
  }

  // Update student attendance
  Future<void> updateStudentAttendance(String batchId, String studentId, bool isPresent) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('batches')
        .doc(batchId)
        .collection('students')
        .doc(studentId)
        .update({'isPresent': isPresent});
  }
} 