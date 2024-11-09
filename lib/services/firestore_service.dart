import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


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
  Future<DocumentReference> addBatch(String name, String year, IconData icon, String title) async {
    try {
      return await _firestore.collection('users').doc(userId).collection('batches').add({
        'batchName': name,
        'batchYear': year,
        'icon': icon.codePoint,
        'title': title,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding batch: $e');
      rethrow;
    }
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
  Future<void> addStudent(String batchId, Map<String, dynamic> studentData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('batches')
        .doc(batchId)
        .collection('students')
        .add(studentData);
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

  // Add this new method to FirestoreService class
  Future<void> updateBatch(String batchId, String title, String batchName, String batchYear, int iconCodePoint) async {
    try {
      print('Updating batch with ID: $batchId');
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('batches')
          .doc(batchId)
          .update({
        'title': title,
        'batchName': batchName,
        'batchYear': batchYear,
        'icon': iconCodePoint,
      });
      print('Batch updated successfully');
    } catch (e) {
      print('Error updating batch: $e');
      rethrow;
    }
  }

  // Add new method to save attendance for a specific date
  Future<void> saveAttendanceForDate(String batchId, DateTime date, List<Map<String, dynamic>> attendanceData) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    try {
      // Create a batch write to handle multiple operations
      WriteBatch batch = _firestore.batch();
      
      // First, get all students in the batch
      final studentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('batches')
          .doc(batchId)
          .collection('students')
          .get();

      // Create a map of enrollment numbers to student documents for quick lookup
      final studentDocs = Map.fromEntries(
        studentsSnapshot.docs.map((doc) => MapEntry(
          doc.data()['enrollNumber'] as String,
          doc
        ))
      );
      
      // For each student's attendance
      for (var studentData in attendanceData) {
        final studentDoc = studentDocs[studentData['enrollNumber']];
        if (studentDoc != null) {
          // Add attendance record to student's attendance subcollection
          final attendanceRef = studentDoc.reference.collection('attendance').doc(dateStr);
          batch.set(attendanceRef, {
            'date': Timestamp.fromDate(date),
            'isPresent': studentData['isPresent'],
          });
        }
      }
      
      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error saving attendance: $e');
      rethrow;
    }
  }

  // Add method to get attendance for a specific date
  Stream<QuerySnapshot> getAttendanceForDate(String batchId, String studentId, DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('batches')
        .doc(batchId)
        .collection('students')
        .doc(studentId)
        .collection('attendance')
        .where('date', isEqualTo: Timestamp.fromDate(date))
        .snapshots();
  }
}