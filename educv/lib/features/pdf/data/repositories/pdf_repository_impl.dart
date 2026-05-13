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
    
    // Debug print to see actual response shape
    print('Generate response: ${response.data}');
    
    final apiResponse = ApiResponse<GenerateResponse>.fromJson(
      response.data,
      (data) {
        // Handle different response formats
        if (data is Map<String, dynamic>) {
          return GenerateResponse.fromJson(data);
        } else {
          throw Exception('Invalid response format for CV generation');
        }
      },
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to generate CVs');
    }

    return apiResponse.data!;
  }

  @override
  Future<List<GeneratedCVModel>> getHistory() async {
    final response = await _apiClient.get('/cv/history/');
    
    // Debug print to see actual response shape
    print('History response: ${response.data}');
    
    final apiResponse = ApiResponse<List<GeneratedCVModel>>.fromJson(
      response.data,
      (data) {
        // Handle paginated response format
        if (data is Map<String, dynamic>) {
          // If data contains 'results' key (paginated)
          if (data.containsKey('results')) {
            return ((data['results'] as List?) ?? [])
                .map((e) => GeneratedCVModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          // If data contains 'cvs' key
          else if (data.containsKey('cvs')) {
            return ((data['cvs'] as List?) ?? [])
                .map((e) => GeneratedCVModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          // If data is a map but no known list key, return empty
          else {
            return <GeneratedCVModel>[];
          }
        }
        // If data is directly a list
        else if (data is List) {
          return data
              .map((e) => GeneratedCVModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        // Fallback to empty list
        else {
          return <GeneratedCVModel>[];
        }
      },
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
