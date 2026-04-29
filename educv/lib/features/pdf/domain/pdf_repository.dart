import 'dart:typed_data';
import '../data/models/generated_cv_model.dart';

abstract class PDFRepository {
  Future<GenerateResponse> generateCVs();
  Future<List<GeneratedCVModel>> getHistory();
  Future<Uint8List> downloadPDF(String generatedCvId);
}