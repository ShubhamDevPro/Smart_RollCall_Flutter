import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/models/student.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      'batchName': name,
      'batchYear': year,
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

  // Delete batch and all its students
  Future<void> deleteBatch(String batchId) async {
    // Get reference to the batch
    final batchRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('batches')
        .doc(batchId);

    // Get all students in the batch
    final studentsSnapshot = await batchRef.collection('students').get();

    // Delete all students
    for (var doc in studentsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the batch itself
    await batchRef.delete();
  }
} 