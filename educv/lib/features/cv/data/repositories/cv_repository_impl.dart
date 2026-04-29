import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/cv_repository.dart';
import '../models/cv_models.dart';

class CVRepositoryImpl implements CVRepository {
  final ApiClient _apiClient;

  CVRepositoryImpl(this._apiClient);

  @override
  Future<CVProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.cvProfile);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get profile',
          details: apiResponse.error?.details,
        );
      }

      return CVProfileModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.cvProfile,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to update profile',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> uploadPhoto(File photo) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path),
      });

      final response = await _apiClient.put(
        ApiConstants.cvProfile,
        data: formData,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to upload photo',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<EducationModel>> getEducation() async {
    try {
      final response = await _apiClient.get(ApiConstants.cvEducation);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get education',
          details: apiResponse.error?.details,
        );
      }

      final List<dynamic> educationList = apiResponse.data ?? [];
      return educationList.map((e) => EducationModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<EducationModel> addEducation(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.cvEducation,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to add education',
          details: apiResponse.error?.details,
        );
      }

      return EducationModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<EducationModel> updateEducation(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.cvEducation}$id/',
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to update education',
          details: apiResponse.error?.details,
        );
      }

      return EducationModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> deleteEducation(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.cvEducation}$id/');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to delete education',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<ExperienceModel>> getExperience() async {
    try {
      final response = await _apiClient.get(ApiConstants.cvExperience);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get experience',
          details: apiResponse.error?.details,
        );
      }

      final List<dynamic> experienceList = apiResponse.data ?? [];
      return experienceList.map((e) => ExperienceModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<ExperienceModel> addExperience(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.cvExperience,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to add experience',
          details: apiResponse.error?.details,
        );
      }

      return ExperienceModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<ExperienceModel> updateExperience(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.cvExperience}$id/',
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to update experience',
          details: apiResponse.error?.details,
        );
      }

      return ExperienceModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> deleteExperience(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.cvExperience}$id/');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to delete experience',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<SkillModel>> getSkills() async {
    try {
      final response = await _apiClient.get(ApiConstants.cvSkills);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get skills',
          details: apiResponse.error?.details,
        );
      }

      final List<dynamic> skillsList = apiResponse.data ?? [];
      return skillsList.map((e) => SkillModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<SkillModel> addSkill(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.cvSkills,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to add skill',
          details: apiResponse.error?.details,
        );
      }

      return SkillModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<SkillModel> updateSkill(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.cvSkills}$id/',
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to update skill',
          details: apiResponse.error?.details,
        );
      }

      return SkillModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> deleteSkill(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.cvSkills}$id/');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to delete skill',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<LanguageModel>> getLanguages() async {
    try {
      final response = await _apiClient.get(ApiConstants.cvLanguages);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get languages',
          details: apiResponse.error?.details,
        );
      }

      final List<dynamic> languagesList = apiResponse.data ?? [];
      return languagesList.map((e) => LanguageModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<LanguageModel> addLanguage(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.cvLanguages,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to add language',
          details: apiResponse.error?.details,
        );
      }

      return LanguageModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<LanguageModel> updateLanguage(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.cvLanguages}$id/',
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to update language',
          details: apiResponse.error?.details,
        );
      }

      return LanguageModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> deleteLanguage(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.cvLanguages}$id/');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to delete language',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _apiClient.get(ApiConstants.cvProjects);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get projects',
          details: apiResponse.error?.details,
        );
      }

      final List<dynamic> projectsList = apiResponse.data ?? [];
      return projectsList.map((e) => ProjectModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<ProjectModel> addProject(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.cvProjects,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to add project',
          details: apiResponse.error?.details,
        );
      }

      return ProjectModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.cvProjects}$id/',
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to update project',
          details: apiResponse.error?.details,
        );
      }

      return ProjectModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.cvProjects}$id/');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to delete project',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<CertificationModel>> getCertifications() async {
    try {
      final response = await _apiClient.get(ApiConstants.cvCertifications);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get certifications',
          details: apiResponse.error?.details,
        );
      }

      final List<dynamic> certificationsList = apiResponse.data ?? [];
      return certificationsList.map((e) => CertificationModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<CertificationModel> addCertification(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.cvCertifications,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to add certification',
          details: apiResponse.error?.details,
        );
      }

      return CertificationModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<CertificationModel> updateCertification(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.cvCertifications}$id/',
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to update certification',
          details: apiResponse.error?.details,
        );
      }

      return CertificationModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> deleteCertification(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.cvCertifications}$id/');

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to delete certification',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<int> getCompletionPercentage() async {
    try {
      final response = await _apiClient.get(ApiConstants.cvCompletion);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get completion percentage',
          details: apiResponse.error?.details,
        );
      }

      return apiResponse.data['completion_percentage'] ?? 0;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}