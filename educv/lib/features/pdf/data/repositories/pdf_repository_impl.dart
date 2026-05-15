import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/pdf_repository.dart';
import '../models/generated_cv_model.dart';

class PDFRepositoryImpl implements PDFRepository {
  final ApiClient _apiClient;

  PDFRepositoryImpl(this._apiClient);

  @override
  Future<GenerateResponse> generateCVs() async {
    final response = await _apiClient.post(ApiConstants.cvGenerate);
    
    final apiResponse = ApiResponse<GenerateResponse>.fromJson(
      response.data,
      (data) {
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
    final response = await _apiClient.get(ApiConstants.cvHistory);
    
    final apiResponse = ApiResponse<List<GeneratedCVModel>>.fromJson(
      response.data,
      (data) {
        if (data is Map<String, dynamic>) {
          if (data.containsKey('results')) {
            return ((data['results'] as List?) ?? [])
                .map((e) => GeneratedCVModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          else if (data.containsKey('cvs')) {
            return ((data['cvs'] as List?) ?? [])
                .map((e) => GeneratedCVModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          else {
            return <GeneratedCVModel>[];
          }
        }
        else if (data is List) {
          return data
              .map((e) => GeneratedCVModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
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
      ApiConstants.cvDownload(generatedCvId),
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF');
    }

    return Uint8List.fromList(response.data);
  }
}
