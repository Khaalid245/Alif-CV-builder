import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../data/models/industry_model.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/template_category_model.dart';
import '../../../data/models/template_model.dart';
import '../../../data/models/user_template_preference_model.dart';
import '../../domain/repositories/template_engine_repository.dart';
import '../../data/repositories/template_engine_repository_impl.dart';

class TemplateEngineProvider extends ChangeNotifier {
  final TemplateEngineRepository _repository;

  TemplateEngineProvider(ApiClient apiClient)
      : _repository = TemplateEngineRepositoryImpl(apiClient);

  // State variables
  bool _isLoading = false;
  String? _error;
  
  // Data
  List<IndustryModel> _industries = [];
  List<RoleModel> _roles = [];
  List<TemplateCategoryModel> _categories = [];
  List<TemplateModel> _templates = [];
  List<TemplateModel> _recommendedTemplates = [];
  List<TemplateModel> _popularTemplates = [];
  List<TemplateModel> _recentTemplates = [];
  UserTemplatePreferenceModel? _userPreferences;
  
  // Filters
  String? _selectedCategory;
  String? _selectedIndustry;
  String? _selectedRole;
  String? _selectedLayout;
  bool? _isPremiumFilter;
  String _searchQuery = '';
  
  // Template details
  TemplateModel? _selectedTemplate;
  String? _templatePreview;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<IndustryModel> get industries => _industries;
  List<RoleModel> get roles => _roles;
  List<TemplateCategoryModel> get categories => _categories;
  List<TemplateModel> get templates => _templates;
  List<TemplateModel> get recommendedTemplates => _recommendedTemplates;
  List<TemplateModel> get popularTemplates => _popularTemplates;
  List<TemplateModel> get recentTemplates => _recentTemplates;
  UserTemplatePreferenceModel? get userPreferences => _userPreferences;
  
  String? get selectedCategory => _selectedCategory;
  String? get selectedIndustry => _selectedIndustry;
  String? get selectedRole => _selectedRole;
  String? get selectedLayout => _selectedLayout;
  bool? get isPremiumFilter => _isPremiumFilter;
  String get searchQuery => _searchQuery;
  
  TemplateModel? get selectedTemplate => _selectedTemplate;
  String? get templatePreview => _templatePreview;

  bool get hasActiveFilters =>
      _selectedCategory != null ||
      _selectedIndustry != null ||
      _selectedRole != null ||
      _selectedLayout != null ||
      _isPremiumFilter != null ||
      _searchQuery.isNotEmpty;

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([
      loadIndustries(),
      loadCategories(),
      loadRoles(),
      loadUserPreferences(),
    ]);
    await loadTemplates();
  }

  // Load industries
  Future<void> loadIndustries() async {
    try {
      _industries = await _repository.getIndustries();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load industries: ${e.toString()}');
    }
  }

  // Load roles
  Future<void> loadRoles({String? industrySlug}) async {
    try {
      _roles = await _repository.getRoles(industrySlug: industrySlug);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load roles: ${e.toString()}');
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    }
  }

  // Load templates with filters
  Future<void> loadTemplates() async {
    _setLoading(true);
    try {
      _templates = await _repository.getTemplates(
        category: _selectedCategory,
        industry: _selectedIndustry,
        role: _selectedRole,
        layoutType: _selectedLayout,
        isPremium: _isPremiumFilter,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to load templates: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load recommended templates
  Future<void> loadRecommendedTemplates({int limit = 6}) async {
    try {
      _recommendedTemplates = await _repository.getRecommendedTemplates(limit: limit);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recommendations: ${e.toString()}');
    }
  }

  // Load popular templates
  Future<void> loadPopularTemplates({int limit = 6, int days = 30}) async {
    try {
      _popularTemplates = await _repository.getPopularTemplates(limit: limit, days: days);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load popular templates: ${e.toString()}');
    }
  }

  // Load user preferences
  Future<void> loadUserPreferences() async {
    try {
      _userPreferences = await _repository.getUserPreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load user preferences: ${e.toString()}');
    }
  }

  // Filter methods
  void setCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      loadTemplates();
    }
  }

  void setIndustry(String? industry) {
    if (_selectedIndustry != industry) {
      _selectedIndustry = industry;
      _selectedRole = null;
      loadRoles(industrySlug: industry);
      loadTemplates();
    }
  }

  void setRole(String? role) {
    if (_selectedRole != role) {
      _selectedRole = role;
      loadTemplates();
    }
  }

  void setLayout(String? layout) {
    if (_selectedLayout != layout) {
      _selectedLayout = layout;
      loadTemplates();
    }
  }

  void setPremiumFilter(bool? isPremium) {
    if (_isPremiumFilter != isPremium) {
      _isPremiumFilter = isPremium;
      loadTemplates();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadTemplates();
    }
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedIndustry = null;
    _selectedRole = null;
    _selectedLayout = null;
    _isPremiumFilter = null;
    _searchQuery = '';
    loadTemplates();
  }

  // Template operations
  Future<void> selectTemplate(String slug) async {
    _setLoading(true);
    try {
      _selectedTemplate = await _repository.getTemplate(slug);
      _clearError();
    } catch (e) {
      _setError('Failed to load template: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> previewTemplate(String slug) async {
    _setLoading(true);
    try {
      _templatePreview = await _repository.previewTemplate(slug);
      _clearError();
    } catch (e) {
      _setError('Failed to generate preview: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> renderTemplate(String slug, {Map<String, dynamic>? customBranding}) async {
    _setLoading(true);
    try {
      final result = await _repository.renderTemplate(slug, customBranding: customBranding);
      _clearError();
      return result;
    } catch (e) {
      _setError('Failed to render template: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Favorite operations
  Future<void> toggleFavorite(TemplateModel template) async {
    try {
      if (isFavorite(template)) {
        await _repository.unfavoriteTemplate(template.slug);
      } else {
        await _repository.favoriteTemplate(template.slug);
      }
      
      // Refresh template data
      await selectTemplate(template.slug);
    } catch (e) {
      _setError('Failed to update favorites: ${e.toString()}');
    }
  }

  bool isFavorite(TemplateModel template) {
    return template.isFavorited;
  }

  // Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      _userPreferences = await _repository.updateUserPreferences(preferences);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update preferences: ${e.toString()}');
    }
  }

  // Add to recent templates
  void addToRecent(TemplateModel template) {
    _recentTemplates.removeWhere((t) => t.id == template.id);
    _recentTemplates.insert(0, template);
    if (_recentTemplates.length > 10) {
      _recentTemplates = _recentTemplates.take(10).toList();
    }
    notifyListeners();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void clearSelectedTemplate() {
    _selectedTemplate = null;
    _templatePreview = null;
    notifyListeners();
  }
}