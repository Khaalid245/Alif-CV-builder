import '../../../data/models/industry_model.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/template_category_model.dart';
import '../../../data/models/template_model.dart';
import '../../../data/models/user_template_preference_model.dart';

abstract class TemplateEngineRepository {
  // Industries
  Future<List<IndustryModel>> getIndustries();
  
  // Roles
  Future<List<RoleModel>> getRoles({String? industrySlug});
  
  // Categories
  Future<List<TemplateCategoryModel>> getCategories();
  
  // Templates
  Future<List<TemplateModel>> getTemplates({
    String? category,
    String? industry,
    String? role,
    String? layoutType,
    bool? isPremium,
    String? search,
    int? page,
    int? limit,
  });
  
  Future<TemplateModel> getTemplate(String slug);
  
  Future<List<TemplateModel>> getRecommendedTemplates({int limit = 10});
  
  Future<List<TemplateModel>> getPopularTemplates({int limit = 10, int days = 30});
  
  Future<String> previewTemplate(String slug);
  
  Future<Map<String, dynamic>> renderTemplate(String slug, {Map<String, dynamic>? customBranding});
  
  // Favorites
  Future<void> favoriteTemplate(String slug);
  
  Future<void> unfavoriteTemplate(String slug);
  
  // User Preferences
  Future<UserTemplatePreferenceModel> getUserPreferences();
  
  Future<UserTemplatePreferenceModel> updateUserPreferences(Map<String, dynamic> preferences);
}