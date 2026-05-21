class UserTemplatePreferenceModel {
  final String id;
  final String userId;
  final List<String> favoriteTemplateIds;
  final List<String> recentTemplateIds;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserTemplatePreferenceModel({
    required this.id,
    required this.userId,
    this.favoriteTemplateIds = const [],
    this.recentTemplateIds = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserTemplatePreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserTemplatePreferenceModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      favoriteTemplateIds: List<String>.from(json['favorite_templates'] ?? []),
      recentTemplateIds: List<String>.from(json['recent_templates'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'favorite_templates': favoriteTemplateIds,
      'recent_templates': recentTemplateIds,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getter for backward compatibility
  List<String> get favoriteTemplates => favoriteTemplateIds;

  UserTemplatePreferenceModel copyWith({
    String? id,
    String? userId,
    List<String>? favoriteTemplateIds,
    List<String>? recentTemplateIds,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserTemplatePreferenceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      favoriteTemplateIds: favoriteTemplateIds ?? this.favoriteTemplateIds,
      recentTemplateIds: recentTemplateIds ?? this.recentTemplateIds,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}