class CVProfileModel {
  final String id;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String linkedin;
  final String github;
  final String portfolio;
  final String? photoUrl;
  final String summary;
  final int completionPercentage;
  final String fullName;
  final String email;
  final String studentId;
  final List<EducationModel> education;
  final List<ExperienceModel> experiences;
  final List<SkillModel> skills;
  final List<LanguageModel> languages;
  final List<ProjectModel> projects;
  final List<CertificationModel> certifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CVProfileModel({
    required this.id,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.linkedin,
    required this.github,
    required this.portfolio,
    this.photoUrl,
    required this.summary,
    required this.completionPercentage,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.education,
    required this.experiences,
    required this.skills,
    required this.languages,
    required this.projects,
    required this.certifications,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CVProfileModel.fromJson(Map<String, dynamic> json) {
    return CVProfileModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      linkedin: json['linkedin'] ?? '',
      github: json['github'] ?? '',
      portfolio: json['portfolio'] ?? '',
      photoUrl: json['photo'],
      summary: json['summary'] ?? '',
      completionPercentage: json['completion_percentage'] ?? 0,
      fullName: json['student']?['full_name'] ?? '',
      email: json['student']?['email'] ?? '',
      studentId: json['student']?['student_id'] ?? '',
      education: (json['educations'] as List<dynamic>?)
              ?.map((e) => EducationModel.fromJson(e))
              .toList() ??
          [],
      experiences: (json['experiences'] as List<dynamic>?)
              ?.map((e) => ExperienceModel.fromJson(e))
              .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => SkillModel.fromJson(e))
              .toList() ??
          [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => LanguageModel.fromJson(e))
              .toList() ??
          [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => ProjectModel.fromJson(e))
              .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => CertificationModel.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'linkedin': linkedin,
      'github': github,
      'portfolio': portfolio,
      'photo': photoUrl,
      'summary': summary,
      'completion_percentage': completionPercentage,
    };
  }

  CVProfileModel copyWith({
    String? id,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? linkedin,
    String? github,
    String? portfolio,
    String? photoUrl,
    String? summary,
    int? completionPercentage,
    String? fullName,
    String? email,
    String? studentId,
    List<EducationModel>? education,
    List<ExperienceModel>? experiences,
    List<SkillModel>? skills,
    List<LanguageModel>? languages,
    List<ProjectModel>? projects,
    List<CertificationModel>? certifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CVProfileModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      portfolio: portfolio ?? this.portfolio,
      photoUrl: photoUrl ?? this.photoUrl,
      summary: summary ?? this.summary,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      education: education ?? this.education,
      experiences: experiences ?? this.experiences,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class EducationModel {
  final String id;
  final String degree;
  final String fieldOfStudy;
  final String institution;
  final int startYear;
  final int? endYear;
  final bool isCurrent;
  final double? gpa;
  final String description;
  final int order;

  const EducationModel({
    required this.id,
    required this.degree,
    required this.fieldOfStudy,
    required this.institution,
    required this.startYear,
    this.endYear,
    required this.isCurrent,
    this.gpa,
    required this.description,
    required this.order,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] ?? '',
      degree: json['degree'] ?? '',
      fieldOfStudy: json['field_of_study'] ?? '',
      institution: json['institution'] ?? '',
      startYear: json['start_year'] ?? 0,
      endYear: json['end_year'],
      isCurrent: json['is_current'] ?? false,
      gpa: json['gpa'] != null
          ? double.tryParse(json['gpa'].toString())
          : null,
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'institution': institution,
      'start_year': startYear,
      'end_year': endYear,
      'is_current': isCurrent,
      'gpa': gpa,
      'description': description,
      'order': order,
    };
  }

  EducationModel copyWith({
    String? id,
    String? degree,
    String? fieldOfStudy,
    String? institution,
    int? startYear,
    int? endYear,
    bool? isCurrent,
    double? gpa,
    String? description,
    int? order,
  }) {
    return EducationModel(
      id: id ?? this.id,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      institution: institution ?? this.institution,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      isCurrent: isCurrent ?? this.isCurrent,
      gpa: gpa ?? this.gpa,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }
}

class ExperienceModel {
  final String id;
  final String jobTitle;
  final String company;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String description;
  final int order;

  const ExperienceModel({
    required this.id,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.description,
    required this.order,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] ?? '',
      jobTitle: json['job_title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isCurrent: json['is_current'] ?? false,
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_title': jobTitle,
      'company': company,
      'location': location,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'is_current': isCurrent,
      'description': description,
      'order': order,
    };
  }

  ExperienceModel copyWith({
    String? id,
    String? jobTitle,
    String? company,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? description,
    int? order,
  }) {
    return ExperienceModel(
      id: id ?? this.id,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }
}

class SkillModel {
  final String id;
  final String name;
  final String level;
  final String category;
  final int order;

  const SkillModel({
    required this.id,
    required this.name,
    required this.level,
    required this.category,
    required this.order,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? 'intermediate',
      category: json['category'] ?? 'technical',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'category': category,
      'order': order,
    };
  }

  SkillModel copyWith({
    String? id,
    String? name,
    String? level,
    String? category,
    int? order,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      category: category ?? this.category,
      order: order ?? this.order,
    );
  }
}

class LanguageModel {
  final String id;
  final String language;
  final String proficiency;

  const LanguageModel({
    required this.id,
    required this.language,
    required this.proficiency,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? '',
      language: json['language'] ?? '',
      proficiency: json['proficiency'] ?? 'conversational',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'proficiency': proficiency,
    };
  }

  LanguageModel copyWith({
    String? id,
    String? language,
    String? proficiency,
  }) {
    return LanguageModel(
      id: id ?? this.id,
      language: language ?? this.language,
      proficiency: proficiency ?? this.proficiency,
    );
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String link;
  final DateTime? startDate;
  final DateTime? endDate;
  final int order;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    this.startDate,
    this.endDate,
    required this.order,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'link': link,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'order': order,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? link,
    DateTime? startDate,
    DateTime? endDate,
    int? order,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      order: order ?? this.order,
    );
  }
}

class CertificationModel {
  final String id;
  final String name;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String credentialUrl;

  const CertificationModel({
    required this.id,
    required this.name,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    required this.credentialUrl,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      issuer: json['issuer'] ?? '',
      issueDate: DateTime.parse(json['issue_date'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      credentialUrl: json['credential_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'issue_date': issueDate.toIso8601String().split('T')[0],
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
      'credential_url': credentialUrl,
    };
  }

  CertificationModel copyWith({
    String? id,
    String? name,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? credentialUrl,
  }) {
    return CertificationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      credentialUrl: credentialUrl ?? this.credentialUrl,
    );
  }
}