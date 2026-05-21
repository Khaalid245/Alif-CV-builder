import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/repositories/template_engine_repository.dart';
import '../../../data/models/industry_model.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/template_category_model.dart';
import '../../../data/models/template_model.dart';
import '../../../data/models/user_template_preference_model.dart';

class TemplateEngineRepositoryImpl implements TemplateEngineRepository {
  final ApiClient _apiClient;

  TemplateEngineRepositoryImpl(this._apiClient);

  @override
  Future<List<IndustryModel>> getIndustries() async {
    try {
      final response = await _apiClient.get(ApiConstants.industries);
      
      if (response.success) {
        final List<dynamic> data = response.responseData as List<dynamic>;
        return data.map((json) => IndustryModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to fetch industries');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<RoleModel>> getRoles({String? industrySlug}) async {
    try {
      final queryParams = <String, String>{};
      if (industrySlug != null) {
        queryParams['industry'] = industrySlug;
      }
      
      final response = await _apiClient.get(ApiConstants.roles, queryParameters: queryParams);
      
      if (response.success) {
        final List<dynamic> data = response.responseData as List<dynamic>;
        return data.map((json) => RoleModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to fetch roles');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<TemplateCategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.categories);
      
      if (response.success) {
        final List<dynamic> data = response.responseData as List<dynamic>;
        return data.map((json) => TemplateCategoryModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to fetch categories');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<TemplateModel>> getTemplates({
    String? category,
    String? industry,
    String? role,
    String? layoutType,
    bool? isPremium,
    String? search,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (category != null) queryParams['category'] = category;
      if (industry != null) queryParams['industry'] = industry;
      if (role != null) queryParams['role'] = role;
      if (layoutType != null) queryParams['layout_type'] = layoutType;
      if (isPremium != null) queryParams['is_premium'] = isPremium.toString();
      if (search != null) queryParams['search'] = search;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final response = await _apiClient.get(ApiConstants.templates, queryParameters: queryParams);
      
      if (response.success) {
        final data = response.responseData;
        
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          final List<dynamic> results = data['results'] as List<dynamic>;
          return results.map((json) => TemplateModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        
        if (data is List<dynamic>) {
          return data.map((json) => TemplateModel.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to fetch templates');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<TemplateModel> getTemplate(String slug) async {
    try {
      final response = await _apiClient.get('${ApiConstants.templates}$slug/');
      
      if (response.success) {
        return TemplateModel.fromJson(response.responseData as Map<String, dynamic>);
      }
      
      throw AppException(message: response.error?.message ?? 'Template not found');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<TemplateModel>> getRecommendedTemplates({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.recommendedTemplates,
        queryParameters: {'limit': limit.toString()},
      );
      
      if (response.success) {
        final List<dynamic> data = response.responseData as List<dynamic>;
        return data.map((json) => TemplateModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to fetch recommendations');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<TemplateModel>> getPopularTemplates({int limit = 10, int days = 30}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.popularTemplates,
        queryParameters: {
          'limit': limit.toString(),
          'days': days.toString(),
        },
      );
      
      if (response.success) {
        final data = response.responseData;
        
        if (data is List<dynamic>) {
          return data.map((json) => TemplateModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        
        if (data is Map<String, dynamic> && data.containsKey('templates')) {
          final List<dynamic> templates = data['templates'] as List<dynamic>;
          return templates.map((json) => TemplateModel.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to fetch popular templates');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<String> previewTemplate(String slug) async {
    try {
      final response = await _apiClient.post('${ApiConstants.templates}$slug/preview/');
      
      if (response.success) {
        return response.responseData['preview_html'] as String;
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to generate preview');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> renderTemplate(String slug, {Map<String, dynamic>? customBranding}) async {
    try {
      final requestData = <String, dynamic>{};
      if (customBranding != null) {
        requestData['custom_branding'] = customBranding;
      }
      
      final response = await _apiClient.post(
        '${ApiConstants.templates}$slug/render/',
        data: requestData,
      );
      
      if (response.success) {
        return response.responseData as Map<String, dynamic>;
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to render template');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<void> favoriteTemplate(String slug) async {
    try {
      final response = await _apiClient.post('${ApiConstants.templates}$slug/favorite/');
      
      if (!response.success) {
        throw AppException(message: response.error?.message ?? 'Failed to favorite template');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<void> unfavoriteTemplate(String slug) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.templates}$slug/unfavorite/');
      
      if (!response.success) {
        throw AppException(message: response.error?.message ?? 'Failed to unfavorite template');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<UserTemplatePreferenceModel> getUserPreferences() async {
    try {
      final response = await _apiClient.get(ApiConstants.templatePreferences);
      
      if (response.success) {
        return UserTemplatePreferenceModel.fromJson(response.responseData as Map<String, dynamic>);
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to fetch preferences');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<UserTemplatePreferenceModel> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await _apiClient.put(ApiConstants.templatePreferences, data: preferences);
      
      if (response.success) {
        return UserTemplatePreferenceModel.fromJson(response.responseData as Map<String, dynamic>);
      }
      
      throw AppException(message: response.error?.message ?? 'Failed to update preferences');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }
}