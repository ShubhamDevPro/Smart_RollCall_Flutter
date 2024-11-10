import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class ExcelExportUtil {
  static Excel generateExcelFile(
      List<Map<String, dynamic>> data, DateTime selectedDate) {
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
      final totalDays = record['totalDays'] ?? 0;
      final presentDays = record['presentDays'] ?? 0;
      final attendancePercentage = totalDays > 0
          ? (presentDays / totalDays * 100).toStringAsFixed(1)
          : '0.0';

      sheet.appendRow([
        selectedDate.toString().split(' ')[0],
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

  static Future<void> exportAttendanceData({
    required List<Map<String, dynamic>> data,
    required DateTime selectedDate,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    try {
      if (data.isEmpty) {
        throw 'No attendance data available to export';
      }

      final excel = generateExcelFile(data, selectedDate);
      final List<int>? excelBytes = excel.encode();

      if (excelBytes == null) {
        throw 'Failed to generate Excel file';
      }

      final fileName =
          'attendance_${selectedDate.toString().split(' ')[0]}.xlsx';

      if (kIsWeb) {
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
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(excelBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Attendance Report for ${selectedDate.toString().split(' ')[0]}',
        );

        if (await file.exists()) {
          await file.delete();
        }
      }

      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }
}
