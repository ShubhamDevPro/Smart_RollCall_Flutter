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
    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Attendance');
    final sheet = excel['Attendance'];

    // Get unique dates from attendance data
    final Set<String> attendanceDates = {};
    for (var record in data) {
      if (record['attendance'] != null) {
        attendanceDates
            .addAll((record['attendance'] as Map).keys.cast<String>());
      }
    }
    final List<String> sortedDates = attendanceDates.toList()..sort();

    // Create headers
    List<TextCellValue> headers = [
      TextCellValue('Name'),
      TextCellValue('Enrollment Number'),
    ];

    // Add date columns with reformatted dates (YYYY-MM-DD to DD-MM-YYYY)
    headers.addAll(sortedDates.map((date) {
      final parts = date.split('-');
      if (parts.length == 3) {
        return TextCellValue('${parts[2]}-${parts[1]}-${parts[0]}');
      }
      return TextCellValue(date);
    }));

    // Add summary columns
    headers.addAll([
      TextCellValue('Total Days'),
      TextCellValue('Present Days'),
      TextCellValue('Attendance %')
    ]);
    sheet.appendRow(headers);

    // Add data rows
    for (var record in data) {
      List<CellValue> row = [
        TextCellValue(record['name'] ?? ''),
        TextCellValue(record['enrollNumber'] ?? ''),
      ];

      // Add attendance status for each date
      int presentCount = 0;
      for (var date in sortedDates) {
        var status = 'NA';
        if (record['attendance']?[date] != null) {
          status = record['attendance'][date] ? 'Present' : 'Absent';
          if (record['attendance'][date]) presentCount++;
        }
        row.add(TextCellValue(status));
      }

      // Calculate and add summary data
      final totalDays = sortedDates
          .where((date) => record['attendance']?[date] != null)
          .length;
      final attendancePercentage = totalDays > 0
          ? (presentCount / totalDays * 100).toStringAsFixed(1)
          : '0.0';

      row.addAll([
        TextCellValue(totalDays.toString()),
        TextCellValue(presentCount.toString()),
        TextCellValue('$attendancePercentage%')
      ]);

      sheet.appendRow(row);
    }

    // Auto-fit columns
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
