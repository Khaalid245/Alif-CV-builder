import '../utils/date_formatter.dart';

class FileSaver {
  static Future<String> saveFile({
    required List<int> bytes,
    required String fileName,
    String? directory,
  }) async {
    final timestamp = DateFormatter.fileDate(DateTime.now());
    final finalFileName = '${timestamp}_$fileName';
    
    // In a real implementation, this would save to device storage
    // For now, return a mock path
    return '/downloads/$finalFileName';
  }

  static Future<String> savePDF({
    required List<int> bytes,
    required String fileName,
    String? templateName, // Optional alias for backward compatibility
    String? directory,
  }) async {
    // Use templateName if provided, otherwise use fileName
    final finalFileName = templateName ?? fileName;
    return saveFile(bytes: bytes, fileName: finalFileName, directory: directory);
  }

  static Future<bool> openFile(String filePath) async {
    // Mock implementation - would use url_launcher or similar
    return true;
  }
}