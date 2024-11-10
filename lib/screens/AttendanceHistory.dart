import 'package:flutter/material.dart';
import 'package:smart_roll_call_flutter/services/firestore_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

/// Screen widget to display and manage attendance history
class AttendanceHistoryScreen extends StatefulWidget {
  final String? batchId;

  const AttendanceHistoryScreen({Key? key, this.batchId}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> attendanceData = [];
  List<Map<String, dynamic>> filteredAttendanceData = [];
  bool isLoading = false;

  // Add text controller for search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  // Add search method
  void _filterAttendance(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAttendanceData = attendanceData;
      } else {
        filteredAttendanceData = attendanceData.where((student) {
          final nameLower = student['name'].toString().toLowerCase();
          final enrollLower = student['enrollNumber'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return nameLower.contains(searchLower) ||
              enrollLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _firestoreService.getAttendanceForDateAll(
        selectedDate,
        widget.batchId,
      );
      setState(() {
        attendanceData = data;
        filteredAttendanceData = data; // Update filtered data too
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance: $e')),
      );
    }
  }

  /// Updates the attendance status for a student
  Future<void> _updateAttendanceStatus(Map<String, dynamic> student) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Toggle the attendance status
      final newStatus = !student['isPresent'];

      await _firestoreService.updateAttendanceStatus(
        student['batchId'],
        student['enrollNumber'],
        selectedDate,
        newStatus,
      );

      // Refresh the attendance data
      await _loadAttendanceData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating attendance: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _exportToExcel() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _firestoreService.getAllAttendanceData();
      final dataList =
          data is Map ? [data] : data as List<Map<String, dynamic>>;
      final excel = await generateExcelFile(dataList);
      final List<int>? excelBytes = excel.encode();

      if (excelBytes == null) throw 'Failed to generate Excel file';

      await ExcelExport.downloadExcel(
        excelBytes,
        'attendance_report.xlsx',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance data exported successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // In AttendanceHistory.dart, update the exportAttendanceData method:

Future<void> exportAttendanceData() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Get attendance data for the selected date and batch
    final data = await _firestoreService.getAttendanceForDateAll(
      selectedDate,
      widget.batchId,
    );
    if (data.isEmpty) {
      throw 'No attendance data available to export';
    }
    
    // Generate Excel file
    final excel = generateExcelFile(data);
    final List<int>? excelBytes = excel.encode();

    if (excelBytes == null) {
      throw 'Failed to generate Excel file';
    }

    final fileName = 'attendance_${selectedDate.toString().split(' ')[0]}.xlsx';

    if (kIsWeb) {
      // Web platform
      final blob = html.Blob([excelBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..style.display = 'none';
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile/Desktop platforms
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(excelBytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Attendance Report for ${selectedDate.toString().split(' ')[0]}',
      );

      // Clean up temporary file
      if (await file.exists()) {
        await file.delete();
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance data exported successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error exporting data: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

// In AttendanceHistory.dart, update the generateExcelFile method:

Excel generateExcelFile(List<Map<String, dynamic>> data) {
  final excel = Excel.createExcel();
  final sheet = excel['Attendance'];

  // Add headers
  sheet.appendRow([
    'Date', 
    'Name', 
    'Enrollment Number', 
    'Status', 
    'Total Days', 
    'Present Days', 
    'Attendance %'
  ]);

  // Add data rows
  for (var record in data) {
    // Calculate attendance percentage
    final totalDays = record['totalDays'] ?? 0;
    final presentDays = record['presentDays'] ?? 0;
    final attendancePercentage = totalDays > 0 
        ? (presentDays / totalDays * 100).toStringAsFixed(1) 
        : '0.0';

    sheet.appendRow([
      selectedDate.toString().split(' ')[0], // Format date as YYYY-MM-DD
      record['name'] ?? '',
      record['enrollNumber'] ?? '',
      record['isPresent'] == true ? 'Present' : 'Absent',
      totalDays.toString(),
      presentDays.toString(),
      '$attendancePercentage%'
    ]);
  }

  // Auto-fit columns
  for (var i = 0; i < sheet.maxCols; i++) {
    sheet.setColWidth(i, 15.0);
  }

  return excel;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          // Add export button in AppBar
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: exportAttendanceData,
            tooltip: 'Export Attendance Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          selectedDate =
                              selectedDate.subtract(const Duration(days: 1));
                          _loadAttendanceData();
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                            _loadAttendanceData();
                          });
                        }
                      },
                      child: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: selectedDate.isBefore(DateTime.now())
                          ? () {
                              setState(() {
                                selectedDate =
                                    selectedDate.add(const Duration(days: 1));
                                _loadAttendanceData();
                              });
                            }
                          : null,
                    ),
                  ],
                ),
                // Add Search TextField
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or enrollment number',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterAttendance('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _filterAttendance,
                  ),
                ),
              ],
            ),
          ),

          // Attendance Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(
                  'Total',
                  filteredAttendanceData.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  'Present',
                  filteredAttendanceData
                      .where((s) => s['isPresent'])
                      .length
                      .toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Absent',
                  filteredAttendanceData
                      .where((s) => !s['isPresent'])
                      .length
                      .toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ),

          // Attendance List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAttendanceData.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No attendance records for this date'
                              : 'No students found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAttendanceData.length,
                        itemBuilder: (context, index) {
                          final student = filteredAttendanceData[index];
                          return AttendanceHistoryCard(
                            name: student['name'],
                            enrollNumber: student['enrollNumber'],
                            isPresent: student['isPresent'],
                            onStatusChanged: () =>
                                _updateAttendanceStatus(student),
                            totalDays: student['totalDays'] ?? 0,
                            presentDays: student['presentDays'] ?? 0,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for displaying attendance history cards
class AttendanceHistoryCard extends StatelessWidget {
  final String name;
  final String enrollNumber;
  final bool isPresent;
  final VoidCallback onStatusChanged;
  final int totalDays;
  final int presentDays;

  const AttendanceHistoryCard({
    required this.name,
    required this.enrollNumber,
    required this.isPresent,
    required this.onStatusChanged,
    this.totalDays = 0,
    this.presentDays = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attendancePercentage = totalDays > 0
        ? (presentDays / totalDays * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onStatusChanged,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Attendance Statistics
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$presentDays/$totalDays',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '$attendancePercentage%',
                    style: TextStyle(
                      fontSize: 12,
                      color: double.parse(attendancePercentage) >= 75
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Present/Absent Icon
              CircleAvatar(
                backgroundColor: isPresent
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Icon(
                  isPresent ? Icons.check : Icons.close,
                  color: isPresent ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('Enrollment No: $enrollNumber'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPresent
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                    color: isPresent ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onStatusChanged,
                tooltip: 'Change attendance status',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExcelExport {
  static Future<void> downloadExcel(
      List<int> excelBytes, String fileName) async {
    if (kIsWeb) {
      final blob = html.Blob([excelBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }
}
