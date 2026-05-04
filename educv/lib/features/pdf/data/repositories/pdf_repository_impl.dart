import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/pdf_repository.dart';
import '../models/generated_cv_model.dart';

class PDFRepositoryImpl implements PDFRepository {
  final ApiClient _apiClient;

  PDFRepositoryImpl(this._apiClient);

  @override
  Future<GenerateResponse> generateCVs() async {
    final response = await _apiClient.post('/cv/generate/');
    final apiResponse = ApiResponse<GenerateResponse>.fromJson(
      response.data,
      (data) => GenerateResponse.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to generate CVs');
    }

    return apiResponse.data!;
  }

  @override
  Future<List<GeneratedCVModel>> getHistory() async {
    final response = await _apiClient.get('/cv/history/');
    final apiResponse = ApiResponse<List<GeneratedCVModel>>.fromJson(
      response.data,
      (data) => (data as List)
          .map((e) => GeneratedCVModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get CV history');
    }

    return apiResponse.data ?? [];
  }

  @override
  Future<Uint8List> downloadPDF(String generatedCvId) async {
    final response = await _apiClient.get(
      '/cv/download/$generatedCvId/',
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF');
    }

    return Uint8List.fromList(response.data);
  }
}
