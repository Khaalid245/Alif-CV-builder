class RoleModel {
  final String id;
  final String name;
  final String description;
  final String slug;
  final String industryId;
  final int templateCount;
  final bool isActive;
  final DateTime createdAt;

  const RoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    required this.industryId,
    required this.templateCount,
    required this.isActive,
    required this.createdAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      slug: json['slug'] ?? '',
      industryId: json['industry_id'] ?? '',
      templateCount: json['template_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
      'industry_id': industryId,
      'template_count': templateCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}