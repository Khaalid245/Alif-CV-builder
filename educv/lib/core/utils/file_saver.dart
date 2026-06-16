import 'dart:typed_data';
import 'date_formatter.dart';
import 'file_saver_platform_io.dart'
    if (dart.library.html) 'file_saver_platform_web.dart';

class FileSaver {
  static Future<String> saveFile({
    required List<int> bytes,
    required String fileName,
    String? directory,
  }) async {
    final timestamp = DateFormatter.fileDate(DateTime.now());
    final finalFileName = '${timestamp}_$fileName';
    final uint8list = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    return savePdfForPlatform(bytes: uint8list, fileName: finalFileName);
  }

  static Future<String> savePDF({
    required List<int> bytes,
    required String fileName,
    String? templateName, // Optional alias for backward compatibility
    String? directory,
  }) async {
    // Ensure the filename has .pdf extension
    String finalFileName = templateName ?? fileName;
    if (!finalFileName.toLowerCase().endsWith('.pdf')) {
      finalFileName = '${finalFileName}_CV.pdf';
    }
    return saveFile(
        bytes: bytes, fileName: finalFileName, directory: directory);
  }

  static Future<bool> openFile(String filePath) async {
    try {
      await openFileForPlatform(filePath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
