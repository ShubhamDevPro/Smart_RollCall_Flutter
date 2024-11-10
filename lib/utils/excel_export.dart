import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class ExcelExport {
  static Future<void> downloadExcel(List<int> bytes, String fileName) async {
    try {
      if (kIsWeb) {
        // Web implementation
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile implementation
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Attendance Report',
        );
        
        // Clean up temporary file
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to export file: $e');
    }
  }
}