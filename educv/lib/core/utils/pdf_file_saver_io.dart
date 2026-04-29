import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> savePdfFileForPlatform({
  required List<int> bytes,
  required String fileName,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}${Platform.pathSeparator}$fileName');

  await file.writeAsBytes(bytes, flush: true);
  await OpenFilex.open(file.path);
}
