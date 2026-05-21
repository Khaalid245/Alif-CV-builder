import 'template_category_model.dart';
import 'industry_model.dart';
import 'role_model.dart';

enum TemplateLayout {
  classic,
  modern,
  academic,
  creative,
  minimal,
  singleColumn,
  twoColumn,
  threeColumn,
  modernGrid,
  timeline
}

enum TemplateStatus {
  draft,
  active,
  archived,
  deprecated
}

class TemplateModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? previewUrl;
  final String? previewImageUrl;
  final bool isPopular;
  final bool isFavorited;
  final bool isPremium;
  final bool isActive;
  final String layoutDisplayName;
  final int usageCount;
  final int templateCount;
  final String version;
  final String? htmlTemplate;
  final String? cssStyles;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TemplateCategoryModel category;
  final List<IndustryModel> industries;
  final List<RoleModel> roles;
  final TemplateLayout layout;
  final TemplateLayout layoutType;
  final TemplateStatus status;
  final String? industryId;
  final String? industry;

  TemplateModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.previewUrl,
    this.previewImageUrl,
    this.isPopular = false,
    this.isFavorited = false,
    this.isPremium = false,
    this.isActive = true,
    this.layoutDisplayName = 'Standard',
    this.usageCount = 0,
    required this.templateCount,
    this.version = '1.0.0',
    this.htmlTemplate,
    this.cssStyles,
    this.createdAt,
    this.updatedAt,
    required this.category,
    this.industries = const [],
    this.roles = const [],
    this.layout = TemplateLayout.classic,
    TemplateLayout? layoutType,
    this.status = TemplateStatus.active,
    this.industryId,
    this.industry,
  }) : layoutType = layoutType ?? layout;

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      previewUrl: json['preview_url'],
      previewImageUrl: json['preview_image_url'],
      isPopular: json['is_popular'] ?? false,
      isFavorited: json['is_favorited'] ?? false,
      isPremium: json['is_premium'] ?? false,
      isActive: json['is_active'] ?? true,
      layoutDisplayName: json['layout_display_name'] ?? 'Standard',
      usageCount: json['usage_count'] ?? 0,
      templateCount: json['template_count'] ?? 0,
      version: json['version'] ?? '1.0.0',
      htmlTemplate: json['html_template'],
      cssStyles: json['css_styles'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      category: TemplateCategoryModel.fromJson(json['category'] ?? {}),
      industries: (json['industries'] as List<dynamic>?)
          ?.map((e) => IndustryModel.fromJson(e))
          .toList() ?? [],
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => RoleModel.fromJson(e))
          .toList() ?? [],
      layout: _parseLayout(json['layout']),
      layoutType: _parseLayout(json['layout_type'] ?? json['layout']),
      status: _parseStatus(json['status']),
      industryId: json['industry_id']?.toString(),
      industry: json['industry']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'preview_url': previewUrl,
      'preview_image_url': previewImageUrl,
      'is_popular': isPopular,
      'is_favorited': isFavorited,
      'is_premium': isPremium,
      'is_active': isActive,
      'layout_display_name': layoutDisplayName,
      'usage_count': usageCount,
      'template_count': templateCount,
      'version': version,
      'html_template': htmlTemplate,
      'css_styles': cssStyles,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': category.toJson(),
      'industries': industries.map((e) => e.toJson()).toList(),
      'roles': roles.map((e) => e.toJson()).toList(),
      'layout': layout.name,
      'layout_type': layoutType.name,
      'status': status.name,
      'industry_id': industryId,
      'industry': industry,
    };
  }

  static TemplateLayout _parseLayout(dynamic value) {
    if (value == null) return TemplateLayout.classic;
    switch (value.toString().toLowerCase()) {
      case 'modern':
        return TemplateLayout.modern;
      case 'academic':
        return TemplateLayout.academic;
      case 'creative':
        return TemplateLayout.creative;
      case 'minimal':
        return TemplateLayout.minimal;
      case 'singlecolumn':
      case 'single_column':
        return TemplateLayout.singleColumn;
      case 'twocolumn':
      case 'two_column':
        return TemplateLayout.twoColumn;
      case 'threecolumn':
      case 'three_column':
        return TemplateLayout.threeColumn;
      case 'moderngrid':
      case 'modern_grid':
        return TemplateLayout.modernGrid;
      case 'timeline':
        return TemplateLayout.timeline;
      default:
        return TemplateLayout.classic;
    }
  }

  static TemplateStatus _parseStatus(dynamic value) {
    if (value == null) return TemplateStatus.active;
    switch (value.toString().toLowerCase()) {
      case 'draft':
        return TemplateStatus.draft;
      case 'archived':
        return TemplateStatus.archived;
      case 'deprecated':
        return TemplateStatus.deprecated;
      default:
        return TemplateStatus.active;
    }
  }
}