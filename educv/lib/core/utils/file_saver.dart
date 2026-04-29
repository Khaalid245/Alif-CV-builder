import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../exceptions/app_exception.dart';
import '../utils/date_formatter.dart';

// Conditional import for web
import 'dart:js_interop' as js;
import 'package:web/web.dart' as web;

class FileSaver {
  static Future<String> savePDF({
    required Uint8List bytes,
    required String templateName,
  }) async {
    final timestamp = DateFormatter.fileDate(DateTime.now());
    final fileName = 'EduCV_${templateName}_$timestamp.pdf';

    if (kIsWeb) {
      _downloadWeb(bytes, fileName);
      return fileName;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }

  static void _downloadWeb(Uint8List bytes, String fileName) {
    final blob = web.Blob([bytes.toJS].toJS);
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..click();
    web.URL.revokeObjectURL(url);
  }

  static Future<void> openFile(String filePath) async {
    if (!kIsWeb) {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw AppException('Could not open file');
      }
    }
  }
}