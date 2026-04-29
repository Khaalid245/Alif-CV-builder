import 'pdf_file_saver_io.dart'
    if (dart.library.html) 'pdf_file_saver_web.dart';

Future<void> savePdfFile({
  required List<int> bytes,
  required String fileName,
}) {
  return savePdfFileForPlatform(bytes: bytes, fileName: fileName);
}
