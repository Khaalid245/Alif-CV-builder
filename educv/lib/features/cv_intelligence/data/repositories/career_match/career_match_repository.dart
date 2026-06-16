import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../models/career_match_models.dart';

final careerMatchRepositoryProvider = Provider<CareerMatchRepository>((ref) {
  return CareerMatchRepository(apiClient: ref.watch(apiClientProvider));
});

class CareerMatchRepository {
  final ApiClient _apiClient;

  CareerMatchRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<CareerMatchResult> analyzeMatch(String cvId, String jobDescription) async {
    try {
      final response = await _apiClient.post(
        '/cv/review/match/',
        data: {
          'cv_id': cvId,
          'job_description': jobDescription,
        },
      );
      
      return CareerMatchResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to analyze career match: $e');
    }
  }
}
