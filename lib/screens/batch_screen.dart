import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/screens/AttendanceScreen.dart';


class BatchScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getBatches(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['title']),
              subtitle: Text('${data['batchName']} ${data['batchYear']}'),
              leading: Icon(IconData(data['icon'], fontFamily: 'MaterialIcons')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(batchId: doc.id),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
} 