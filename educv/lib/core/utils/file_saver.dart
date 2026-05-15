import 'dart:typed_data';

import '../utils/date_formatter.dart';
import 'file_saver_platform_io.dart'
    if (dart.library.html) 'file_saver_platform_web.dart';

class FileSaver {
  static Future<String> savePDF({
    required Uint8List bytes,
    required String templateName,
  }) async {
    final timestamp = DateFormatter.fileDate(DateTime.now());
    final fileName = 'EduCV_${templateName}_$timestamp.pdf';

    return savePdfForPlatform(bytes: bytes, fileName: fileName);
  }

  static Future<void> openFile(String filePath) async {
    await openFileForPlatform(filePath);
  }
}
