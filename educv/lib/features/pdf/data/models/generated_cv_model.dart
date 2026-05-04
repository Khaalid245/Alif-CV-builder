class GeneratedCVModel {
  final String id;
  final String template;
  final String templateDisplay;
  final String downloadUrl;
  final DateTime generatedAt;
  final int downloadCount;

  const GeneratedCVModel({
    required this.id,
    required this.template,
    required this.templateDisplay,
    required this.downloadUrl,
    required this.generatedAt,
    required this.downloadCount,
  });

  factory GeneratedCVModel.fromJson(Map<String, dynamic> json) {
    return GeneratedCVModel(
      id: json['id']?.toString() ?? '',
      template: json['template']?.toString() ?? '',
      templateDisplay: json['template_display']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString() ?? '',
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      downloadCount: (json['download_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template': template,
      'template_display': templateDisplay,
      'download_url': downloadUrl,
      'generated_at': generatedAt.toIso8601String(),
      'download_count': downloadCount,
    };
  }

  String get templateDescription {
    switch (template) {
      case 'classic':
        return 'Traditional layout, ideal for corporate and government applications';
      case 'modern':
        return 'Clean contemporary design, perfect for tech and startup roles';
      case 'academic':
        return 'Structured format for research, scholarships and postgraduate study';
      default:
        return '';
    }
  }

  String get templateBadge {
    switch (template) {
      case 'classic':
        return 'Professional';
      case 'modern':
        return 'Popular';
      case 'academic':
        return 'Academic';
      default:
        return '';
    }
  }
}

class GenerateResponse {
  final DateTime generatedAt;
  final List<GeneratedCVModel> cvs;

  const GenerateResponse({
    required this.generatedAt,
    required this.cvs,
  });

  factory GenerateResponse.fromJson(Map<String, dynamic> json) {
    return GenerateResponse(
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      cvs: json['cvs'] != null
          ? (json['cvs'] as List)
              .map((e) => GeneratedCVModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generated_at': generatedAt.toIso8601String(),
      'cvs': cvs.map((cv) => cv.toJson()).toList(),
    };
  }
}
