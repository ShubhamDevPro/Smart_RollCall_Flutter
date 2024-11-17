// File: excel_export.dart
// Purpose: Utility class for exporting attendance data to Excel format
// Supports both web and mobile platforms

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

/// Utility class for handling Excel export operations
class ExcelExportUtil {
  /// Generates an Excel workbook from attendance data
  /// @param data List of attendance records
  /// @param selectedDate Date for which attendance is being exported
  /// @returns Excel workbook object
  static Excel generateExcelFile(
      List<Map<String, dynamic>> data, DateTime selectedDate) {
    // Create new Excel workbook and worksheet
    final excel = Excel.createExcel();
    
    // Rename Sheet1 to Attendance
    excel.rename('Sheet1', 'Attendance');
    
    final sheet = excel['Attendance'];

    // Define and add column headers to the first row
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Name'),
      TextCellValue('Enrollment Number'),
      TextCellValue('Status'),
      TextCellValue('Total Days'),
      TextCellValue('Present Days'),
      TextCellValue('Attendance %')
    ]);

    // Iterate through attendance records and add data rows
    for (var record in data) {
      // Calculate attendance percentage
      final totalDays = record['totalDays'] ?? 0;
      final presentDays = record['presentDays'] ?? 0;
      final attendancePercentage = totalDays > 0
          ? (presentDays / totalDays * 100).toStringAsFixed(1)
          : '0.0';

      // Add row with formatted data
      sheet.appendRow([
        TextCellValue(selectedDate.toString().split(' ')[0]), // Date in YYYY-MM-DD format
        TextCellValue(record['name'] ?? ''),
        TextCellValue(record['enrollNumber'] ?? ''),
        TextCellValue(record['isPresent'] == true ? 'Present' : 'Absent'),
        TextCellValue(totalDays.toString()),
        TextCellValue(presentDays.toString()),
        TextCellValue('$attendancePercentage%')
      ]);
    }

    // Set uniform column widths for better readability
    for (var i = 0; i < sheet.maxColumns; i++) {
      sheet.setColAutoFit(i);
    }

    return excel;
  }

  /// Exports attendance data to an Excel file
  /// Handles platform-specific file saving/sharing
  /// @param data List of attendance records to export
  /// @param selectedDate Date for which attendance is being exported
  /// @param onError Callback for error handling
  /// @param onSuccess Callback for successful export
  static Future<void> exportAttendanceData({
    required List<Map<String, dynamic>> data,
    required DateTime selectedDate,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    try {
      // Validate input data
      if (data.isEmpty) {
        throw 'No attendance data available to export';
      }

      // Generate Excel file and get bytes
      final excel = generateExcelFile(data, selectedDate);
      final List<int>? excelBytes = excel.encode();

      if (excelBytes == null) {
        throw 'Failed to generate Excel file';
      }

      // Generate filename with date
      final fileName =
          'attendance_${selectedDate.toString().split(' ')[0]}.xlsx';

      if (kIsWeb) {
        // Web platform: Create download link
        final blob = html.Blob([excelBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        // Create and trigger download
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..style.display = 'none';
        html.document.body?.children.add(anchor);
        anchor.click();
        
        // Clean up
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile platform: Save to temp directory and share
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(excelBytes);

        // Show native share dialog
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Attendance Report for ${selectedDate.toString().split(' ')[0]}',
        );

        // Clean up temporary file
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Notify success
      onSuccess();
    } catch (e) {
      // Handle and report errors
      onError(e.toString());
    }
  }
}

extension on Sheet {
  void setColAutoFit(int i) {}
}
