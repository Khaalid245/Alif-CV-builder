import 'dart:io';
import '../data/models/cv_models.dart';

abstract class CVRepository {
  // Profile operations
  Future<CVProfileModel> getProfile();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> uploadPhoto(File photo);

  // Education operations
  Future<List<EducationModel>> getEducation();
  Future<EducationModel> addEducation(Map<String, dynamic> data);
  Future<EducationModel> updateEducation(String id, Map<String, dynamic> data);
  Future<void> deleteEducation(String id);

  // Experience operations
  Future<List<ExperienceModel>> getExperience();
  Future<ExperienceModel> addExperience(Map<String, dynamic> data);
  Future<ExperienceModel> updateExperience(String id, Map<String, dynamic> data);
  Future<void> deleteExperience(String id);

  // Skills operations
  Future<List<SkillModel>> getSkills();
  Future<SkillModel> addSkill(Map<String, dynamic> data);
  Future<SkillModel> updateSkill(String id, Map<String, dynamic> data);
  Future<void> deleteSkill(String id);

  // Languages operations
  Future<List<LanguageModel>> getLanguages();
  Future<LanguageModel> addLanguage(Map<String, dynamic> data);
  Future<LanguageModel> updateLanguage(String id, Map<String, dynamic> data);
  Future<void> deleteLanguage(String id);

  // Projects operations
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> addProject(Map<String, dynamic> data);
  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data);
  Future<void> deleteProject(String id);

  // Certifications operations
  Future<List<CertificationModel>> getCertifications();
  Future<CertificationModel> addCertification(Map<String, dynamic> data);
  Future<CertificationModel> updateCertification(String id, Map<String, dynamic> data);
  Future<void> deleteCertification(String id);

  // Completion percentage
  Future<int> getCompletionPercentage();
}