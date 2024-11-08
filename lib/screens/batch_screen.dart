import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';
import 'package:smart_roll_call_flutter/screens/AttendanceScreen.dart';

class BatchScreen extends StatelessWidget {
  BatchScreen({super.key});
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
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  data['title'] ?? 'Untitled',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${data['batchName'] ?? ''} ${data['batchYear'] ?? ''}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    IconData(data['icon'] ?? Icons.book.codePoint, 
                      fontFamily: 'MaterialIcons'
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceScreen(batchId: doc.id),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
} 