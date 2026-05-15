import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<String> savePdfForPlatform({
  required Uint8List bytes,
  required String fileName,
}) async {
  final blob = web.Blob([bytes.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;

  anchor.click();
  web.URL.revokeObjectURL(url);
  return fileName;
}

Future<void> openFileForPlatform(String filePath) async {
  // Browser downloads are triggered by savePdfForPlatform.
}
