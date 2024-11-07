import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_roll_call_flutter/models/student.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Get batches for current user
  Stream<QuerySnapshot> getBatches() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('batches')
        .snapshots();
  }

  // Add new batch
  Future<void> addBatch(String name, String year) {
    return _firestore.collection('users').doc(userId).collection('batches').add({
      'name': name,
      'year': year,
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
} 