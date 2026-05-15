import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../exceptions/app_exception.dart';

Future<String> savePdfForPlatform({
  required Uint8List bytes,
  required String fileName,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<void> openFileForPlatform(String filePath) async {
  final result = await OpenFilex.open(filePath);
  if (result.type != ResultType.done) {
    throw const AppException('Could not open file');
  }
}
