import 'dart:html' as html;

Future<void> downloadExcelFile(List<int> excelBytes, String fileName) async {
  final blob = html.Blob([excelBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
