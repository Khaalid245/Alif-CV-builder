import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/cv_repository.dart';
import '../models/cv_models.dart';

class CVRepositoryImpl implements CVRepository {
  final ApiClient _apiClient;

  CVRepositoryImpl(this._apiClient);

  dynamic _responseData(dynamic responseData) {
    return responseData is Map<String, dynamic> ? responseData['data'] : null;
  }

  List<dynamic> _responseList(dynamic responseData) {
    final data = _responseData(responseData);
    if (data is List<dynamic>) {
      return data;
    }
    return [];
  }

  @override
  Future<CVProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get('/cv/profile/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to get profile');
      }
      return CVProfileModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to get profile: $e');
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/cv/profile/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw AppException(message: 'Failed to update profile: $e');
    }
  }

  @override
  Future<void> uploadPhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path),
      });
      final response = await _apiClient.put('/cv/profile/', data: formData);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to upload photo');
      }
    } catch (e) {
      throw AppException(message: 'Failed to upload photo: $e');
    }
  }

  @override
  Future<List<EducationModel>> getEducation() async {
    try {
      final response = await _apiClient.get('/cv/education/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to get education');
      }
      final data = _responseList(response.data);
      return data.map((e) => EducationModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException(message: 'Failed to get education: $e');
    }
  }

  @override
  Future<EducationModel> addEducation(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/cv/education/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to add education');
      }
      return EducationModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to add education: $e');
    }
  }

  @override
  Future<EducationModel> updateEducation(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/cv/education/$id/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to update education');
      }
      return EducationModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to update education: $e');
    }
  }

  @override
  Future<void> deleteEducation(String id) async {
    try {
      final response = await _apiClient.delete('/cv/education/$id/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to delete education');
      }
    } catch (e) {
      throw AppException(message: 'Failed to delete education: $e');
    }
  }

  @override
  Future<List<ExperienceModel>> getExperience() async {
    try {
      final response = await _apiClient.get('/cv/experience/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to get experience');
      }
      final data = _responseList(response.data);
      return data.map((e) => ExperienceModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException(message: 'Failed to get experience: $e');
    }
  }

  @override
  Future<ExperienceModel> addExperience(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/cv/experience/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to add experience');
      }
      return ExperienceModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to add experience: $e');
    }
  }

  @override
  Future<ExperienceModel> updateExperience(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/cv/experience/$id/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to update experience');
      }
      return ExperienceModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to update experience: $e');
    }
  }

  @override
  Future<void> deleteExperience(String id) async {
    try {
      final response = await _apiClient.delete('/cv/experience/$id/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to delete experience');
      }
    } catch (e) {
      throw AppException(message: 'Failed to delete experience: $e');
    }
  }

  @override
  Future<List<SkillModel>> getSkills() async {
    try {
      final response = await _apiClient.get('/cv/skills/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to get skills');
      }
      final data = _responseList(response.data);
      return data.map((e) => SkillModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException(message: 'Failed to get skills: $e');
    }
  }

  @override
  Future<SkillModel> addSkill(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/cv/skills/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to add skill');
      }
      return SkillModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to add skill: $e');
    }
  }

  @override
  Future<SkillModel> updateSkill(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/cv/skills/$id/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to update skill');
      }
      return SkillModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to update skill: $e');
    }
  }

  @override
  Future<void> deleteSkill(String id) async {
    try {
      final response = await _apiClient.delete('/cv/skills/$id/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to delete skill');
      }
    } catch (e) {
      throw AppException(message: 'Failed to delete skill: $e');
    }
  }

  @override
  Future<List<LanguageModel>> getLanguages() async {
    try {
      final response = await _apiClient.get('/cv/languages/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to get languages');
      }
      final data = _responseList(response.data);
      return data.map((e) => LanguageModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException(message: 'Failed to get languages: $e');
    }
  }

  @override
  Future<LanguageModel> addLanguage(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/cv/languages/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to add language');
      }
      return LanguageModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to add language: $e');
    }
  }

  @override
  Future<LanguageModel> updateLanguage(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/cv/languages/$id/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to update language');
      }
      return LanguageModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to update language: $e');
    }
  }

  @override
  Future<void> deleteLanguage(String id) async {
    try {
      final response = await _apiClient.delete('/cv/languages/$id/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to delete language');
      }
    } catch (e) {
      throw AppException(message: 'Failed to delete language: $e');
    }
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _apiClient.get('/cv/projects/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to get projects');
      }
      final data = _responseList(response.data);
      return data.map((e) => ProjectModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException(message: 'Failed to get projects: $e');
    }
  }

  @override
  Future<ProjectModel> addProject(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/cv/projects/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to add project');
      }
      return ProjectModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to add project: $e');
    }
  }

  @override
  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/cv/projects/$id/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to update project');
      }
      return ProjectModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to update project: $e');
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      final response = await _apiClient.delete('/cv/projects/$id/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to delete project');
      }
    } catch (e) {
      throw AppException(message: 'Failed to delete project: $e');
    }
  }

  @override
  Future<List<CertificationModel>> getCertifications() async {
    try {
      final response = await _apiClient.get('/cv/certifications/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to get certifications');
      }
      final data = _responseList(response.data);
      return data.map((e) => CertificationModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException(message: 'Failed to get certifications: $e');
    }
  }

  @override
  Future<CertificationModel> addCertification(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/cv/certifications/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to add certification');
      }
      return CertificationModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to add certification: $e');
    }
  }

  @override
  Future<CertificationModel> updateCertification(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/cv/certifications/$id/', data: data);
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to update certification');
      }
      return CertificationModel.fromJson(response.data['data']);
    } catch (e) {
      throw AppException(message: 'Failed to update certification: $e');
    }
  }

  @override
  Future<void> deleteCertification(String id) async {
    try {
      final response = await _apiClient.delete('/cv/certifications/$id/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to delete certification');
      }
    } catch (e) {
      throw AppException(message: 'Failed to delete certification: $e');
    }
  }

  @override
  Future<int> getCompletionPercentage() async {
    try {
      final response = await _apiClient.get('/cv/completion/');
      if (response.data['success'] == false) {
        throw AppException(message: response.data['message'] ?? 'Failed to get completion percentage');
      }
      return response.data['data']['completion_percentage'] ?? 0;
    } catch (e) {
      throw AppException(message: 'Failed to get completion percentage: $e');
    }
  }
}
