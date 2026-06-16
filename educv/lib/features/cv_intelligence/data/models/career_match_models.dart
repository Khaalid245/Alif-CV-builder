class MissingSkill {
  final String name;
  final String importance;
  final int estimatedImprovement;

  MissingSkill({
    required this.name,
    required this.importance,
    required this.estimatedImprovement,
  });

  factory MissingSkill.fromJson(Map<String, dynamic> json) {
    return MissingSkill(
      name: json['name'] as String,
      importance: json['importance'] as String,
      estimatedImprovement: json['estimated_improvement'] as int,
    );
  }
}

class ImprovementAction {
  final String action;
  final int estimatedImprovement;

  ImprovementAction({
    required this.action,
    required this.estimatedImprovement,
  });

  factory ImprovementAction.fromJson(Map<String, dynamic> json) {
    return ImprovementAction(
      action: json['action'] as String,
      estimatedImprovement: json['estimated_improvement'] as int,
    );
  }
}

class JobFitCategories {
  final int technicalSkills;
  final int communication;
  final int leadership;
  final int projects;
  final int education;
  final int experience;

  JobFitCategories({
    required this.technicalSkills,
    required this.communication,
    required this.leadership,
    required this.projects,
    required this.education,
    required this.experience,
  });

  factory JobFitCategories.fromJson(Map<String, dynamic> json) {
    return JobFitCategories(
      technicalSkills: json['technical_skills'] as int,
      communication: json['communication'] as int,
      leadership: json['leadership'] as int,
      projects: json['projects'] as int,
      education: json['education'] as int,
      experience: json['experience'] as int,
    );
  }
}

class CareerMatchResult {
  final int overallMatch;
  final String status;
  final List<String> strengths;
  final List<MissingSkill> missingSkills;
  final List<String> presentKeywords;
  final List<String> missingKeywords;
  final List<String> recommendedKeywords;
  final List<ImprovementAction> improvementPlan;
  final JobFitCategories categories;

  CareerMatchResult({
    required this.overallMatch,
    required this.status,
    required this.strengths,
    required this.missingSkills,
    required this.presentKeywords,
    required this.missingKeywords,
    required this.recommendedKeywords,
    required this.improvementPlan,
    required this.categories,
  });

  factory CareerMatchResult.fromJson(Map<String, dynamic> json) {
    return CareerMatchResult(
      overallMatch: json['overall_match'] as int,
      status: json['status'] as String,
      strengths: List<String>.from(json['strengths'] ?? []),
      missingSkills: (json['missing_skills'] as List?)
              ?.map((e) => MissingSkill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      presentKeywords: List<String>.from(json['present_keywords'] ?? []),
      missingKeywords: List<String>.from(json['missing_keywords'] ?? []),
      recommendedKeywords: List<String>.from(json['recommended_keywords'] ?? []),
      improvementPlan: (json['improvement_plan'] as List?)
              ?.map((e) => ImprovementAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: JobFitCategories.fromJson(json['categories'] as Map<String, dynamic>),
    );
  }
}
