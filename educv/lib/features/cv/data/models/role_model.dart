/// Role Intelligence model.
/// Represents a target role a user can associate with their CV.
/// Fetched from GET /api/v1/cv/roles/
class RoleModel {
  final String id;
  final String name;
  final String slug;
  final String industry;
  final String icon;
  final String summaryGuidance;
  final List<String> recommendedMetrics;

  const RoleModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.industry,
    required this.icon,
    this.summaryGuidance = '',
    this.recommendedMetrics = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      industry: json['industry'] as String,
      icon: json['icon'] as String? ?? 'briefcase',
      summaryGuidance: json['summary_guidance'] as String? ?? '',
      recommendedMetrics: (json['recommended_metrics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'industry': industry,
        'icon': icon,
        'summary_guidance': summaryGuidance,
        'recommended_metrics': recommendedMetrics,
      };

  @override
  String toString() => '$name ($industry)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
