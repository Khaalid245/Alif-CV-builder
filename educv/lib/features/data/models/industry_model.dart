class IndustryModel {
  final String id;
  final String name;
  final String description;
  final String slug;
  final int templateCount;
  final bool isActive;
  final DateTime createdAt;

  const IndustryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    required this.templateCount,
    required this.isActive,
    required this.createdAt,
  });

  factory IndustryModel.fromJson(Map<String, dynamic> json) {
    return IndustryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      slug: json['slug'] ?? '',
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
      'template_count': templateCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}