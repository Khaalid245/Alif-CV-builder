import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/cv_repository.dart';
import '../../data/repositories/cv_repository_impl.dart';
import '../../data/models/cv_models.dart';

// Repository provider
final cvRepositoryProvider = Provider<CVRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CVRepositoryImpl(apiClient);
});

// CV Profile provider
final cvProfileProvider = AsyncNotifierProvider<CVProfileNotifier, CVProfileModel>(() {
  return CVProfileNotifier();
});

class CVProfileNotifier extends AsyncNotifier<CVProfileModel> {
  @override
  Future<CVProfileModel> build() async {
    final repository = ref.read(cvRepositoryProvider);
    return await repository.getProfile();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.updateProfile(data);
      final updatedProfile = await repository.getProfile();
      state = AsyncValue.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> uploadPhoto(File photo) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.uploadPhoto(photo);
      final updatedProfile = await repository.getProfile();
      state = AsyncValue.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      final profile = await repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
    final repository = ref.read(cvRepositoryProvider);
    return await repository.getEducation();
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newEducation = await repository.addEducation(data);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newEducation]);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateEducation(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedEducation = await repository.updateEducation(id, data);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((e) => e.id == id ? updatedEducation : e).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteEducation(id);
      final currentList = state.value ?? [];
      final updatedList = currentList.where((e) => e.id != id).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      final education = await repository.getEducation();
      state = AsyncValue.data(education);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
    final repository = ref.read(cvRepositoryProvider);
    return await repository.getExperience();
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newExperience = await repository.addExperience(data);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newExperience]);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateExperience(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedExperience = await repository.updateExperience(id, data);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((e) => e.id == id ? updatedExperience : e).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteExperience(id);
      final currentList = state.value ?? [];
      final updatedList = currentList.where((e) => e.id != id).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      final experience = await repository.getExperience();
      state = AsyncValue.data(experience);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
    final repository = ref.read(cvRepositoryProvider);
    return await repository.getSkills();
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newSkill = await repository.addSkill(data);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newSkill]);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSkill(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedSkill = await repository.updateSkill(id, data);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((e) => e.id == id ? updatedSkill : e).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteSkill(id);
      final currentList = state.value ?? [];
      final updatedList = currentList.where((e) => e.id != id).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      final skills = await repository.getSkills();
      state = AsyncValue.data(skills);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
    final repository = ref.read(cvRepositoryProvider);
    return await repository.getLanguages();
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newLanguage = await repository.addLanguage(data);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newLanguage]);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateLanguage(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedLanguage = await repository.updateLanguage(id, data);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((e) => e.id == id ? updatedLanguage : e).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteLanguage(id);
      final currentList = state.value ?? [];
      final updatedList = currentList.where((e) => e.id != id).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      final languages = await repository.getLanguages();
      state = AsyncValue.data(languages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
    final repository = ref.read(cvRepositoryProvider);
    return await repository.getProjects();
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newProject = await repository.addProject(data);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newProject]);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedProject = await repository.updateProject(id, data);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((e) => e.id == id ? updatedProject : e).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteProject(id);
      final currentList = state.value ?? [];
      final updatedList = currentList.where((e) => e.id != id).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      final projects = await repository.getProjects();
      state = AsyncValue.data(projects);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
    final repository = ref.read(cvRepositoryProvider);
    return await repository.getCertifications();
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final newCertification = await repository.addCertification(data);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newCertification]);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCertification(String id, Map<String, dynamic> data) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      final updatedCertification = await repository.updateCertification(id, data);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((e) => e.id == id ? updatedCertification : e).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String id) async {
    try {
      final repository = ref.read(cvRepositoryProvider);
      await repository.deleteCertification(id);
      final currentList = state.value ?? [];
      final updatedList = currentList.where((e) => e.id != id).toList();
      state = AsyncValue.data(updatedList);
      ref.invalidate(cvProfileProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(cvRepositoryProvider);
      final certifications = await repository.getCertifications();
      state = AsyncValue.data(certifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Form step provider
final cvFormStepProvider = StateProvider<int>((ref) => 0);

// Form loading provider
final cvFormLoadingProvider = StateProvider<bool>((ref) => false);
