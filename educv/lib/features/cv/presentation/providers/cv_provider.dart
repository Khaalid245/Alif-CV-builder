import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/cv_repository.dart';
import '../../data/models/cv_models.dart';
import '../../data/repositories/cv_repository_impl.dart';

// Repository provider
final cvRepositoryProvider = Provider<CVRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CVRepositoryImpl(apiClient);
});

// Form step provider
final cvFormStepProvider = StateProvider<int>((ref) => 0);

// Form loading provider
final cvFormLoadingProvider = StateProvider<bool>((ref) => false);

// CV Profile provider
final cvProfileProvider = AsyncNotifierProvider<CVProfileNotifier, CVProfileModel?>(() {
  return CVProfileNotifier();
});

class CVProfileNotifier extends AsyncNotifier<CVProfileModel?> {
  @override
  Future<CVProfileModel?> build() async {
    return await fetch();
  }

  Future<CVProfileModel?> fetch() async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final profile = await repository.getProfile();
      return profile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching CV profile: $e');
      }
      return null;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.updateProfile(data);
      
      // Refresh profile data
      final updatedProfile = await repository.getProfile();
      state = AsyncData(updatedProfile);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> uploadPhoto(File photo) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.uploadPhoto(photo);
      
      // Refresh profile data
      final updatedProfile = await repository.getProfile();
      state = AsyncData(updatedProfile);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Education provider
final educationProvider = AsyncNotifierProvider<EducationNotifier, List<EducationModel>>(() {
  return EducationNotifier();
});

class EducationNotifier extends AsyncNotifier<List<EducationModel>> {
  @override
  Future<List<EducationModel>> build() async {
    return await fetch();
  }

  Future<List<EducationModel>> fetch() async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      return await repository.getEducation();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching education: $e');
      }
      return [];
    }
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newEducation = await repository.addEducation(data);
      
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, newEducation]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedEducation = await repository.updateEducation(id, data);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.map((education) {
        return education.id == id ? updatedEducation : education;
      }).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteEducation(id);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.where((education) => education.id != id).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Experience provider
final experienceProvider = AsyncNotifierProvider<ExperienceNotifier, List<ExperienceModel>>(() {
  return ExperienceNotifier();
});

class ExperienceNotifier extends AsyncNotifier<List<ExperienceModel>> {
  @override
  Future<List<ExperienceModel>> build() async {
    return await fetch();
  }

  Future<List<ExperienceModel>> fetch() async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      return await repository.getExperience();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching experience: $e');
      }
      return [];
    }
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newExperience = await repository.addExperience(data);
      
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, newExperience]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedExperience = await repository.updateExperience(id, data);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.map((experience) {
        return experience.id == id ? updatedExperience : experience;
      }).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteExperience(id);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.where((experience) => experience.id != id).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Skills provider
final skillsProvider = AsyncNotifierProvider<SkillsNotifier, List<SkillModel>>(() {
  return SkillsNotifier();
});

class SkillsNotifier extends AsyncNotifier<List<SkillModel>> {
  @override
  Future<List<SkillModel>> build() async {
    return await fetch();
  }

  Future<List<SkillModel>> fetch() async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      return await repository.getSkills();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching skills: $e');
      }
      return [];
    }
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newSkill = await repository.addSkill(data);
      
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, newSkill]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedSkill = await repository.updateSkill(id, data);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.map((skill) {
        return skill.id == id ? updatedSkill : skill;
      }).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteSkill(id);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.where((skill) => skill.id != id).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Languages provider
final languagesProvider = AsyncNotifierProvider<LanguagesNotifier, List<LanguageModel>>(() {
  return LanguagesNotifier();
});

class LanguagesNotifier extends AsyncNotifier<List<LanguageModel>> {
  @override
  Future<List<LanguageModel>> build() async {
    return await fetch();
  }

  Future<List<LanguageModel>> fetch() async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      return await repository.getLanguages();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching languages: $e');
      }
      return [];
    }
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newLanguage = await repository.addLanguage(data);
      
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, newLanguage]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedLanguage = await repository.updateLanguage(id, data);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.map((language) {
        return language.id == id ? updatedLanguage : language;
      }).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteLanguage(id);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.where((language) => language.id != id).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Projects provider
final projectsProvider = AsyncNotifierProvider<ProjectsNotifier, List<ProjectModel>>(() {
  return ProjectsNotifier();
});

class ProjectsNotifier extends AsyncNotifier<List<ProjectModel>> {
  @override
  Future<List<ProjectModel>> build() async {
    return await fetch();
  }

  Future<List<ProjectModel>> fetch() async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      return await repository.getProjects();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching projects: $e');
      }
      return [];
    }
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newProject = await repository.addProject(data);
      
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, newProject]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedProject = await repository.updateProject(id, data);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.map((project) {
        return project.id == id ? updatedProject : project;
      }).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteProject(id);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.where((project) => project.id != id).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Certifications provider
final certificationsProvider = AsyncNotifierProvider<CertificationsNotifier, List<CertificationModel>>(() {
  return CertificationsNotifier();
});

class CertificationsNotifier extends AsyncNotifier<List<CertificationModel>> {
  @override
  Future<List<CertificationModel>> build() async {
    return await fetch();
  }

  Future<List<CertificationModel>> fetch() async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      return await repository.getCertifications();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching certifications: $e');
      }
      return [];
    }
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newCertification = await repository.addCertification(data);
      
      final currentList = state.value ?? [];
      state = AsyncData([...currentList, newCertification]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedCertification = await repository.updateCertification(id, data);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.map((certification) {
        return certification.id == id ? updatedCertification : certification;
      }).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteCertification(id);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.where((certification) => certification.id != id).toList();
      
      state = AsyncData(updatedList);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
